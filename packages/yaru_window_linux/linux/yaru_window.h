#ifndef YARU_WINDOW_H_
#define YARU_WINDOW_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

void yaru_window_drag(GtkWindow* window);
void yaru_window_hide_title(GtkWindow* window);
void yaru_window_restore(GtkWindow* window);
void yaru_window_show_menu(GtkWindow* window);

FlValue* yaru_window_get_geometry(GtkWindow* window);
void yaru_window_set_geometry(GtkWindow* window, FlValue* geometry);

FlValue* yaru_window_get_state(GtkWindow* window);
void yaru_window_set_state(GtkWindow* window, FlValue* state);

FlValue* yaru_window_get_style(GtkWindow* window);
void yaru_window_set_style(GtkWindow* window, FlValue* style);

G_END_DECLS

#endif  // YARU_WINDOW_H_
