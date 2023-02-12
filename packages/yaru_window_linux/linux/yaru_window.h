#ifndef YARU_WINDOW_H_
#define YARU_WINDOW_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

FlValue* yaru_window_get_state(GtkWindow* window);
void yaru_window_drag(GtkWindow* window);
const gchar* yaru_window_get_title(GtkWindow* window);
void yaru_window_set_title(GtkWindow* window, const gchar* title);
void yaru_window_hide_title(GtkWindow* window);
void yaru_window_show_title(GtkWindow* window);
void yaru_window_restore(GtkWindow* window);
void yaru_window_show_menu(GtkWindow* window);
void yaru_window_set_background(GtkWindow* window, guint color);
void yaru_window_set_brightness(GtkWindow* window, const gchar* brightness);

G_END_DECLS

#endif  // YARU_WINDOW_H_
