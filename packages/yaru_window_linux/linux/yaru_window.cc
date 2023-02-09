#include "yaru_window.h"

static GdkPoint get_cursor_position(GtkWindow* window) {
  GdkWindow* handle = gtk_widget_get_window(GTK_WIDGET(window));
  GdkDisplay* display = gdk_window_get_display(handle);
  GdkSeat* seat = gdk_display_get_default_seat(display);
  GdkDevice* pointer = gdk_seat_get_pointer(seat);
  GdkPoint pos;
  gdk_device_get_position(pointer, nullptr, &pos.x, &pos.y);
  return pos;
}

static GdkPoint get_window_origin(GtkWindow* window) {
  GdkWindow* handle = gtk_widget_get_window(GTK_WIDGET(window));
  GdkPoint pos;
  gdk_window_get_origin(handle, &pos.x, &pos.y);
  return pos;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
static int get_window_background(GtkWindow* window) {
  GdkRGBA color;
  GtkStyleContext* style = gtk_widget_get_style_context(GTK_WIDGET(window));
  gtk_style_context_get_background_color(style, GTK_STATE_FLAG_NORMAL, &color);
  return (static_cast<int>(color.alpha * 255) << 24) |
         (static_cast<int>(color.red * 255) << 16) |
         (static_cast<int>(color.green * 255) << 8) |
         static_cast<int>(color.blue * 255);
}
#pragma GCC diagnostic pop

static void set_window_background(GtkWindow* window, guint color) {
  GdkRGBA rgba = {
      .red = ((color >> 16) & 0xFF) / 255.0,
      .green = ((color >> 8) & 0xFF) / 255.0,
      .blue = (color & 0xFF) / 255.0,
      .alpha = (color >> 24) / 255.0,
  };

  gpointer css_provider = g_object_get_data(G_OBJECT(window), "css_provider");
  if (css_provider == nullptr) {
    css_provider = gtk_css_provider_new();
    gtk_style_context_add_provider(
        gtk_widget_get_style_context(GTK_WIDGET(window)),
        GTK_STYLE_PROVIDER(css_provider),
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_set_data_full(G_OBJECT(window), "css_provider", css_provider,
                           g_object_unref);
  }

  g_autofree gchar* str = gdk_rgba_to_string(&rgba);
  g_autofree gchar* css = g_strdup_printf("window { background: %s; }", str);

  g_autoptr(GError) error = nullptr;
  gtk_css_provider_load_from_data(GTK_CSS_PROVIDER(css_provider), css, -1,
                                  &error);
  if (error != nullptr) {
    g_warning("set_window_background: %s", error->message);
  }
}

// Returns true if the widget is GtkHeaderBar or HdyHeaderBar from libhandy.
static gboolean is_header_bar(GtkWidget* widget) {
  return widget != nullptr &&
         (GTK_IS_HEADER_BAR(widget) ||
          g_str_has_suffix(G_OBJECT_TYPE_NAME(widget), "HeaderBar"));
}

// Recursively searches for a Gtk/HdyHeaderBar in the widget tree.
static GtkWidget* find_header_bar(GtkWidget* widget) {
  if (is_header_bar(widget)) {
    return widget;
  }

  if (GTK_IS_CONTAINER(widget)) {
    g_autoptr(GList) children =
        gtk_container_get_children(GTK_CONTAINER(widget));
    for (GList* l = children; l != nullptr; l = l->next) {
      GtkWidget* header_bar = find_header_bar(GTK_WIDGET(l->data));
      if (header_bar != nullptr) {
        return header_bar;
      }
    }
  }

  return nullptr;
}

void yaru_window_drag(GtkWindow* window) {
  GdkPoint cursor = get_cursor_position(window);
  gtk_window_begin_move_drag(window, GDK_BUTTON_PRIMARY, cursor.x, cursor.y,
                             GDK_CURRENT_TIME);
}

void yaru_window_hide_title(GtkWindow* window) {
  GtkWidget* titlebar = gtk_window_get_titlebar(window);
  if (!is_header_bar(titlebar)) {
    titlebar = find_header_bar(GTK_WIDGET(window));
  }
  if (titlebar != nullptr) {
    gtk_widget_hide(titlebar);
  }
}

void yaru_window_restore(GtkWindow* window) {
  GdkWindow* handle = gtk_widget_get_window(GTK_WIDGET(window));
  GdkWindowState state = gdk_window_get_state(handle);
  if (state & GDK_WINDOW_STATE_FULLSCREEN) {
    gtk_window_unfullscreen(window);
  } else if (state & GDK_WINDOW_STATE_MAXIMIZED) {
    gtk_window_unmaximize(window);
  } else if (state & GDK_WINDOW_STATE_ICONIFIED) {
    gtk_window_deiconify(window);
  }
}

void yaru_window_show_menu(GtkWindow* window) {
  GdkWindow* handle = gtk_widget_get_window(GTK_WIDGET(window));
  GdkDisplay* display = gdk_window_get_display(handle);
  GdkSeat* seat = gdk_display_get_default_seat(display);
  GdkDevice* pointer = gdk_seat_get_pointer(seat);

  GdkPoint cursor = get_cursor_position(window);
  GdkPoint origin = get_window_origin(window);

  g_autoptr(GdkEvent) event = gdk_event_new(GDK_BUTTON_PRESS);
  event->button.button = GDK_BUTTON_SECONDARY;
  event->button.device = pointer;
  event->button.window = handle;
  event->button.x_root = cursor.x;
  event->button.y_root = cursor.y;
  event->button.x = cursor.x - origin.x;
  event->button.y = cursor.y - origin.y;
  gdk_window_show_window_menu(handle, event);
}

FlValue* yaru_window_get_geometry(GtkWindow* window) {
  gint x, y;
  gtk_window_get_position(window, &x, &y);
  gint width, height;
  gtk_window_get_size(window, &width, &height);

  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(result, "id", fl_value_new_int(0));  // TODO
  fl_value_set_string_take(result, "type", fl_value_new_string("geometry"));
  fl_value_set_string_take(result, "x", fl_value_new_int(x));
  fl_value_set_string_take(result, "y", fl_value_new_int(y));
  fl_value_set_string_take(result, "width", fl_value_new_int(width));
  fl_value_set_string_take(result, "height", fl_value_new_int(height));
  return result;
}

void yaru_window_set_geometry(GtkWindow* window, FlValue* geometry) {
  FlValue* x = fl_value_lookup_string(geometry, "x");
  FlValue* y = fl_value_lookup_string(geometry, "y");
  FlValue* width = fl_value_lookup_string(geometry, "width");
  FlValue* height = fl_value_lookup_string(geometry, "height");
  FlValue* maximum_width = fl_value_lookup_string(geometry, "maximumWidth");
  FlValue* maximum_height = fl_value_lookup_string(geometry, "maximumHeight");
  FlValue* minimum_width = fl_value_lookup_string(geometry, "minimumWidth");
  FlValue* minimum_height = fl_value_lookup_string(geometry, "minimumHeight");

  gboolean has_x = fl_value_get_type(x) == FL_VALUE_TYPE_INT;
  gboolean has_y = fl_value_get_type(y) == FL_VALUE_TYPE_INT;
  if (has_x || has_y) {
    GdkPoint pos;
    if (!has_x || !has_y) {
      gtk_window_get_position(window, &pos.x, &pos.y);
    }
    if (has_x) {
      pos.x = fl_value_get_int(x);
    }
    if (has_y) {
      pos.y = fl_value_get_int(y);
    }
    gtk_window_move(window, pos.x, pos.y);
  }

  gboolean has_width = fl_value_get_type(width) == FL_VALUE_TYPE_INT;
  gboolean has_height = fl_value_get_type(height) == FL_VALUE_TYPE_INT;
  if (has_width || has_height) {
    GdkRectangle size;
    if (!has_width || !has_height) {
      gtk_window_get_size(window, &size.width, &size.height);
    }
    if (has_width) {
      size.width = fl_value_get_int(width);
    }
    if (has_height) {
      size.height = fl_value_get_int(height);
    }
    gtk_window_resize(window, size.width, size.height);
  }

  GdkWindowHints mask = GdkWindowHints(0);
  GdkGeometry hints = {
      .min_width = 0,
      .min_height = 0,
      .max_width = G_MAXINT,
      .max_height = G_MAXINT,
  };
  if (fl_value_get_type(maximum_width) == FL_VALUE_TYPE_INT) {
    mask = GdkWindowHints(mask | GDK_HINT_MAX_SIZE);
    hints.max_width = fl_value_get_int(maximum_width);
  }
  if (fl_value_get_type(maximum_height) == FL_VALUE_TYPE_INT) {
    mask = GdkWindowHints(mask | GDK_HINT_MAX_SIZE);
    hints.max_height = fl_value_get_int(maximum_height);
  }
  if (fl_value_get_type(minimum_width) == FL_VALUE_TYPE_INT) {
    mask = GdkWindowHints(mask | GDK_HINT_MIN_SIZE);
    hints.min_width = fl_value_get_int(minimum_width);
  }
  if (fl_value_get_type(minimum_height) == FL_VALUE_TYPE_INT) {
    mask = GdkWindowHints(mask | GDK_HINT_MIN_SIZE);
    hints.min_height = fl_value_get_int(minimum_height);
  }
  if (mask != 0) {
    gtk_window_set_geometry_hints(window, nullptr, &hints, mask);
  }
}

FlValue* yaru_window_get_state(GtkWindow* window) {
  GdkWindow* handle = gtk_widget_get_window(GTK_WIDGET(window));
  GdkWindowState state = gdk_window_get_state(handle);
  GdkWindowTypeHint type = gdk_window_get_type_hint(handle);

  gboolean active = gtk_window_is_active(window);
  gboolean closable = gtk_window_get_deletable(window);
  gboolean fullscreen = state & GDK_WINDOW_STATE_FULLSCREEN;
  gboolean maximized = state & GDK_WINDOW_STATE_MAXIMIZED;
  gboolean minimized = state & GDK_WINDOW_STATE_ICONIFIED;
  gboolean normal = type == GDK_WINDOW_TYPE_HINT_NORMAL;
  gboolean restorable = normal && (fullscreen || maximized || minimized);
  const gchar* title = gtk_window_get_title(window);
  gboolean visible = gtk_widget_is_visible(GTK_WIDGET(window));

  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(result, "id", fl_value_new_int(0));  // TODO
  fl_value_set_string_take(result, "type", fl_value_new_string("state"));
  fl_value_set_string_take(result, "active", fl_value_new_bool(active));
  fl_value_set_string_take(result, "closable", fl_value_new_bool(closable));
  fl_value_set_string_take(result, "fullscreen", fl_value_new_bool(fullscreen));
  fl_value_set_string_take(result, "maximizable",
                           fl_value_new_bool(normal && !maximized));
  fl_value_set_string_take(result, "maximized", fl_value_new_bool(maximized));
  fl_value_set_string_take(result, "minimizable",
                           fl_value_new_bool(normal && !minimized));
  fl_value_set_string_take(result, "minimized", fl_value_new_bool(minimized));
  fl_value_set_string_take(result, "movable", fl_value_new_bool(true));
  fl_value_set_string_take(result, "restorable", fl_value_new_bool(restorable));
  fl_value_set_string_take(result, "title", fl_value_new_string(title));
  fl_value_set_string_take(result, "visible", fl_value_new_bool(visible));
  return result;
}

void yaru_window_set_state(GtkWindow* window, FlValue* state) {
  FlValue* active = fl_value_lookup_string(state, "active");
  FlValue* closable = fl_value_lookup_string(state, "closable");
  FlValue* fullscreen = fl_value_lookup_string(state, "fullscreen");
  FlValue* maximizable = fl_value_lookup_string(state, "maximizable");
  FlValue* maximized = fl_value_lookup_string(state, "maximized");
  FlValue* minimizable = fl_value_lookup_string(state, "minimizable");
  FlValue* minimized = fl_value_lookup_string(state, "minimized");
  FlValue* restorable = fl_value_lookup_string(state, "restorable");
  FlValue* title = fl_value_lookup_string(state, "title");
  FlValue* visible = fl_value_lookup_string(state, "visible");

  if (fl_value_get_type(active) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(active)) {
      gtk_window_present(window);
    }
  }
  if (fl_value_get_type(closable) == FL_VALUE_TYPE_BOOL) {
    gtk_window_set_deletable(window, fl_value_get_bool(closable));
  }
  if (fl_value_get_type(fullscreen) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(fullscreen)) {
      gtk_window_fullscreen(window);
    } else {
      gtk_window_unfullscreen(window);
    }
  }
  if (fl_value_get_type(maximizable) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(maximizable)) {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_NORMAL);
    } else {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_DIALOG);
    }
  }
  if (fl_value_get_type(maximized) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(maximized)) {
      gtk_window_maximize(window);
    } else {
      gtk_window_unmaximize(window);
    }
  }
  if (fl_value_get_type(minimizable) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(minimizable)) {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_NORMAL);
    } else {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_DIALOG);
    }
  }
  if (fl_value_get_type(minimized) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(minimized)) {
      gtk_window_iconify(window);
    } else {
      gtk_window_deiconify(window);
    }
  }
  if (fl_value_get_type(restorable) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(restorable)) {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_NORMAL);
    } else {
      gtk_window_set_type_hint(window, GDK_WINDOW_TYPE_HINT_DIALOG);
    }
  }
  if (fl_value_get_type(title) == FL_VALUE_TYPE_STRING) {
    gtk_window_set_title(window, fl_value_get_string(title));
  }
  if (fl_value_get_type(visible) == FL_VALUE_TYPE_BOOL) {
    if (fl_value_get_bool(visible)) {
      gtk_widget_show(GTK_WIDGET(window));
    } else {
      gtk_widget_hide(GTK_WIDGET(window));
    }
  }
}

FlValue* yaru_window_get_style(GtkWindow* window) {
  gint background = get_window_background(window);
  gdouble opacity = gtk_widget_get_opacity(GTK_WIDGET(window));

  FlValue* result = fl_value_new_map();
  fl_value_set_string_take(result, "id", fl_value_new_int(0));  // TODO
  fl_value_set_string_take(result, "type", fl_value_new_string("style"));
  fl_value_set_string_take(result, "background", fl_value_new_int(background));
  fl_value_set_string_take(result, "opacity", fl_value_new_float(opacity));
  return result;
}

void yaru_window_set_style(GtkWindow* window, FlValue* style) {
  FlValue* background = fl_value_lookup_string(style, "background");
  FlValue* opacity = fl_value_lookup_string(style, "opacity");

  if (fl_value_get_type(background) == FL_VALUE_TYPE_INT) {
    set_window_background(window, fl_value_get_int(background));
  }
  if (fl_value_get_type(opacity) == FL_VALUE_TYPE_FLOAT) {
    gtk_widget_set_opacity(GTK_WIDGET(window), fl_value_get_float(opacity));
  }
}
