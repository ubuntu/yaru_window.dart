#include "include/yaru_window_linux/yaru_window_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "yaru_window.h"

struct _YaruWindowLinuxPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* method_channel;
  FlEventChannel* event_channel;
  GHashTable* signals;
};

G_DEFINE_TYPE(YaruWindowLinuxPlugin, yaru_window_linux_plugin,
              g_object_get_type())

static GtkWindow* yaru_window_linux_plugin_get_window(
    YaruWindowLinuxPlugin* self, gint window_id) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static gboolean window_state_cb(GtkWidget* window, GdkEventWindowState* event,
                                gpointer user_data) {
  FlEventChannel* channel = FL_EVENT_CHANNEL(user_data);
  g_autoptr(FlValue) state = yaru_window_get_state(GTK_WINDOW(window));
  fl_event_channel_send(channel, state, nullptr, nullptr);
  return false;
}

static void window_property_cb(GtkWindow* window, GParamSpec*,
                               gpointer user_data) {
  FlEventChannel* channel = FL_EVENT_CHANNEL(user_data);
  g_autoptr(FlValue) state = yaru_window_get_state(GTK_WINDOW(window));
  fl_event_channel_send(channel, state, nullptr, nullptr);
}

static gboolean window_delete_event_cb(GtkWidget* window, GdkEvent* /*event*/,
                                       gpointer user_data);

static void window_delete_response_cb(GObject* object, GAsyncResult* result,
                                      gpointer user_data) {
  FlMethodChannel* channel = FL_METHOD_CHANNEL(object);
  g_autoptr(GError) error = nullptr;
  g_autoptr(FlMethodResponse) response =
      fl_method_channel_invoke_method_finish(channel, result, &error);
  if (!response) {
    g_warning("onClose response: %s", error->message);
    return;
  }

  FlValue* value = fl_method_response_get_result(response, &error);
  if (value && fl_value_get_type(value) == FL_VALUE_TYPE_BOOL &&
      !fl_value_get_bool(value)) {
    return;
  }

  GtkWindow* window = GTK_WINDOW(user_data);
  g_signal_handlers_disconnect_by_func(window, gpointer(window_delete_event_cb),
                                       channel);
  gtk_window_close(GTK_WINDOW(window));
}

gboolean window_delete_event_cb(GtkWidget* window, GdkEvent* /*event*/,
                                gpointer user_data) {
  FlMethodChannel* channel = FL_METHOD_CHANNEL(user_data);
  g_autoptr(FlValue) args = fl_value_new_int(0);  // TODO
  fl_method_channel_invoke_method(channel, "onClose", args, nullptr,
                                  window_delete_response_cb, window);
  return TRUE;
}

static void yaru_window_linux_plugin_listen_window(YaruWindowLinuxPlugin* self,
                                                   gint window_id) {
  GtkWindow* window = yaru_window_linux_plugin_get_window(self, window_id);
  if (!g_hash_table_contains(self->signals, GINT_TO_POINTER(window_id))) {
    g_signal_connect_object(window, "window-state-event",
                            G_CALLBACK(window_state_cb), self->event_channel,
                            G_CONNECT_DEFAULT);
    g_signal_connect_object(G_OBJECT(window), "notify::deletable",
                            G_CALLBACK(window_property_cb), self->event_channel,
                            G_CONNECT_DEFAULT);
    g_signal_connect_object(G_OBJECT(window), "notify::is-active",
                            G_CALLBACK(window_property_cb), self->event_channel,
                            G_CONNECT_DEFAULT);
    g_signal_connect_object(G_OBJECT(window), "notify::is-maximized",
                            G_CALLBACK(window_property_cb), self->event_channel,
                            G_CONNECT_DEFAULT);
    g_signal_connect_object(G_OBJECT(window), "notify::type-hint",
                            G_CALLBACK(window_property_cb), self->event_channel,
                            G_CONNECT_DEFAULT);
    g_signal_connect_object(G_OBJECT(window), "delete-event",
                            G_CALLBACK(window_delete_event_cb),
                            self->method_channel, G_CONNECT_DEFAULT);
    g_hash_table_insert(self->signals, GINT_TO_POINTER(window_id), 0);
  }
}

static void yaru_window_linux_plugin_unlisten_window(
    YaruWindowLinuxPlugin* self, gint window_id) {
  GtkWindow* window = yaru_window_linux_plugin_get_window(self, window_id);
  if (g_hash_table_contains(self->signals, GINT_TO_POINTER(window_id))) {
    g_signal_handlers_disconnect_by_func(window, gpointer(window_state_cb),
                                         self->event_channel);
    g_signal_handlers_disconnect_by_func(window, gpointer(window_property_cb),
                                         self->event_channel);
    g_signal_handlers_disconnect_by_func(
        window, gpointer(window_delete_event_cb), self->method_channel);
    g_hash_table_remove(self->signals, GINT_TO_POINTER(window_id));
  }
}

static void yaru_window_linux_plugin_handle_method_call(
    YaruWindowLinuxPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  gint window_id = fl_value_get_int(fl_value_get_list_value(args, 0));
  GtkWindow* window = yaru_window_linux_plugin_get_window(self, window_id);

  if (strcmp(method, "close") == 0) {
    gtk_window_close(window);
  } else if (strcmp(method, "drag") == 0) {
    yaru_window_drag(window);
  } else if (strcmp(method, "fullscreen") == 0) {
    gtk_window_fullscreen(window);
  } else if (strcmp(method, "hide") == 0) {
    gtk_widget_hide(GTK_WIDGET(window));
  } else if (strcmp(method, "hideTitle") == 0) {
    yaru_window_hide_title(window);
  } else if (strcmp(method, "showTitle") == 0) {
    yaru_window_show_title(window);
  } else if (strcmp(method, "maximize") == 0) {
    gtk_window_maximize(window);
  } else if (strcmp(method, "minimize") == 0) {
    gtk_window_iconify(window);
  } else if (strcmp(method, "restore") == 0) {
    yaru_window_restore(window);
  } else if (strcmp(method, "show") == 0) {
    gtk_widget_show(GTK_WIDGET(window));
  } else if (strcmp(method, "showMenu") == 0) {
    yaru_window_show_menu(window);
  } else if (strcmp(method, "state") == 0) {
    g_autoptr(FlValue) state = yaru_window_get_state(window);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(state));
  } else if (strcmp(method, "setBackground") == 0) {
    FlValue* background = fl_value_get_list_value(args, 1);
    yaru_window_set_background(window, fl_value_get_int(background));
  } else if (strcmp(method, "setMinimizable") == 0 ||
             strcmp(method, "setMaximizable") == 0) {
    FlValue* minimizable = fl_value_get_list_value(args, 1);
    if (fl_value_get_bool(minimizable)) {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_NORMAL);
    } else {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_DIALOG);
    }
  } else if (strcmp(method, "setClosable") == 0) {
    FlValue* closable = fl_value_get_list_value(args, 1);
    gtk_window_set_deletable(window, fl_value_get_bool(closable));
  } else if (strcmp(method, "setTitle") == 0) {
    FlValue* title = fl_value_get_list_value(args, 1);
    yaru_window_set_title(window, fl_value_get_string(title));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  if (!response) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void yaru_window_linux_plugin_dispose(GObject* object) {
  YaruWindowLinuxPlugin* self = YARU_WINDOW_LINUX_PLUGIN(object);
  g_clear_object(&self->registrar);
  g_clear_object(&self->method_channel);
  g_clear_object(&self->event_channel);
  g_clear_pointer(&self->signals, g_hash_table_unref);
  G_OBJECT_CLASS(yaru_window_linux_plugin_parent_class)->dispose(object);
}

static void yaru_window_linux_plugin_class_init(
    YaruWindowLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = yaru_window_linux_plugin_dispose;
}

static void yaru_window_linux_plugin_init(YaruWindowLinuxPlugin* self) {
  self->signals = g_hash_table_new(g_direct_hash, g_direct_equal);
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  YaruWindowLinuxPlugin* plugin = YARU_WINDOW_LINUX_PLUGIN(user_data);
  yaru_window_linux_plugin_handle_method_call(plugin, method_call);
}

static FlMethodErrorResponse* listen_state_cb(FlEventChannel* channel,
                                              FlValue* args,
                                              gpointer user_data) {
  YaruWindowLinuxPlugin* plugin = YARU_WINDOW_LINUX_PLUGIN(user_data);
  yaru_window_linux_plugin_listen_window(plugin, 0);
  return nullptr;
}

static FlMethodErrorResponse* cancel_state_cb(FlEventChannel* channel,
                                              FlValue* args,
                                              gpointer user_data) {
  YaruWindowLinuxPlugin* plugin = YARU_WINDOW_LINUX_PLUGIN(user_data);
  yaru_window_linux_plugin_unlisten_window(plugin, 0);
  return nullptr;
}

void yaru_window_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  g_autoptr(YaruWindowLinuxPlugin) plugin = YARU_WINDOW_LINUX_PLUGIN(
      g_object_new(yaru_window_linux_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);

  plugin->method_channel =
      fl_method_channel_new(messenger, "yaru_window", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->method_channel, method_call_cb, g_object_ref(plugin),
      g_object_unref);

  plugin->event_channel = fl_event_channel_new(messenger, "yaru_window/events",
                                               FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(plugin->event_channel, listen_state_cb,
                                       cancel_state_cb, g_object_ref(plugin),
                                       g_object_unref);
}
