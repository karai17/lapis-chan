return { pl = {

  --==[[ Navigation ]]==--

  archive       = "Archiwum",
  bottom        = "Przewiń na dół",
  catalog       = "Catalog",
  index         = "Spis treści",
  refresh       = "Odśwież",
  ["return"]    = "Powróć",
  return_board  = "Powróć do boardu",
  return_index  = "Powróć do spisu treści",
  return_thread = "Powróć do wątku",
  top           = "Przewiń na górę",

  --==[[ Error Messages ]]==--

  -- Controller error messages
  err_ban_reason = "Brak powodu.",
  err_board_used = "Nazwa boardu jest już w użyciu.",
  err_not_admin  = "Nie jesteś administratorem.",
  err_orphaned   = "Wątek %s został osierocony.",
  err_url_used   = "Adres URL jest już w użyciu.",
  err_user_used  = "Nazwa użytkownika jest już w użyciu.",

  -- Model error messages
  err_contribute     = "Musisz załączyć treść posta lub załącznik.",
  err_locked_thread  = "Wątek %s jest zablokowany.",
  err_no_files       = "Dodawanie plików jest wyłączone na tym boardzie.",

  err_comment_post   = "Na tym boardzie, by odpowiedzieć na wątek, musisz zamieścić komentarz.",
  err_comment_thread = "Na tym boardzie, by stworzyć wątek, musisz zamieścić komentarz.",

  err_create_ann     = "Nie można utworzyć ogłoszenia: %s.",
  err_create_ban     = "Nie można zbananować IP: %s.",
  err_create_board   = "Nie można utworzyć boarda: /%s/ - %s.",
  err_create_page    = "Nie można utworzyć strony: /%s/ - %s.",
  err_create_post    = "Nie można wysłać posta.",
  err_create_report  = "Nie można zgłosić posta %s.",
  err_create_thread  = "Nie można utworzyć wątku.",

  err_delete_board   = "Nie można usunąć boarda: /%s/ - %s.",
  err_delete_post    = "Nie można usunąć posta %s.",
  err_create_user    = "Nie można utworzyć użytkownika: %s.",

  err_file_exists    = "Ten plik już istnieje na tym boardzie.",
  err_file_limit     = "Wątek %s osiągnął już swój limit plików.",
  err_file_post      = "Na tym boardzie, by odpowiedzieć na wątek, musisz załączyć plik.",
  err_file_thread    = "Na tym boardzie, by stworzyć wątek, musisz załączyć plik.",

  err_invalid_board  = "Nieznany board: /%s/.",
  err_invalid_ext    = "Nieznany typ pliku: %s.",
  err_invalid_image  = "Załączony plik nie jest prawidłowym obrazkiem.",
  err_invalid_post   = "Post %s nie jest poprawnym postem.",
  err_invalid_user   = "Niepoprawna nazwa użytkownika lub hasło.",

  --==[[ 404 ]]==--

  ["404"] = "404 - Strona nie znaleziona",

  --==[[ Administration ]]==--

  -- General
  admin_panel             = "Admin Panel",
  administrator           = "Administrator",
  announcement            = "Announcement",
  archive_days            = "Days to Archive Threads",
  archive_pruned          = "Archive Pruned Threads",
  board                   = "Board",
  board_group             = "Board Group",
  board_name              = "Board Name",
  bump_limit              = "Bump Limit",
  content_md              = "Content (Markdown)",
  default_name            = "Default Name",
  draw_board              = "Draw Board",
  file                    = "Plik",
  file_limit              = "Thread File Limit",
  global                  = "Global",
  index_boards            = "Aktualne boardy",
  janitor                 = "Janitor",
  login                   = "Login",
  logout                  = "Logout",
  moderator               = "Moderator",
  name                    = "Name",
  num_pages               = "Active Pages",
  num_threads             = "Threads per Page",
  password                = "Password",
  password_old            = "Old Password",
  password_retype         = "Retype Password",
  post_comment_required   = "Post Comment Required",
  post_file_required      = "Post File Required",
  regen_thumb             = "Regenerate Thumbnails",
  reply                   = "Reply",
  rules                   = "Zasady",
  short_name              = "Short Name",
  subtext                 = "Subtext",
  success                 = "Success",
  text_board              = "Text Board",
  theme                   = "Theme",
  thread_comment_required = "Thread Comment Required",
  thread_file_required    = "Thread File Required",
  url                     = "URL",
  username                = "Username",
  yes                     = "Yes",
  no                      = "No",

  -- Announcements
  create_ann   = "Create Announcement",
  modify_ann   = "Modify Announcement",
  delete_ann   = "Delete Announcement",
  created_ann  = "You have successfully created announcement: %s.",
  modified_ann = "You have successfully modified announcement: %s.",
  deleted_ann  = "You have successfully deleted announcement: %s.",

  -- Boards
  create_board   = "Create Board",
  modify_board   = "Modify Board",
  delete_board   = "Delete Board",
  created_board  = "You have successfully created board: /%s/ - %s.",
  modified_board = "You have successfully modified board: /%s/ - %s.",
  deleted_board  = "You have successfully deleted board: /%s/ - %s.",

  -- Pages
  create_page   = "Create Page",
  modify_page   = "Modify Page",
  delete_page   = "Delete Page",
  created_page  = "You have successfully created page: /%s/ - %s.",
  modified_page = "You have successfully modified page: /%s/ - %s.",
  deleted_page  = "You have successfully deleted page: /%s/ - %s.",

  -- Reports
  view_report    = "View Report",
  delete_report  = "Delete Report",
  deleted_report = "You have successfully deleted report: %s.",

  -- Users
  create_user   = "Create User",
  modify_user   = "Modify User",
  delete_user   = "Delete User",
  created_user  = "You have successfully created user: %s.",
  modified_user = "You have successfully modified user: %s.",
  deleted_user  = "You have successfully deleted user: %s.",

  --==[[ Archive ]]==--

  arc_display = "Wyświetlanie %{n_thread} %{p_thread} (zarchiwizowane) z %{n_day} %{p_day}",
  arc_number  = "nr ",
  arc_name    = "Nazwa",
  arc_excerpt = "Kawał freda",
  arc_replies = "Odpowiedzi",
  arc_view    = "Wyślij",

  --==[[ Ban ]]==--

  ban_title  = "Zbanowany!",
  ban_reason = "Zostałeś zbananowany z powodu o takiego:",
  ban_expire = "Twój banan usunie się %{expire}.",
  ban_ip     = "Według naszych serwerów NASA, twoje IP to %{ip}.",

  --==[[ Catalog ]]==--

  cat_stats = "Odp.: %{replies} / plików: %{files}",

  --==[[ Copyright ]]==--

  copy_software = "Fredy napędzane przez %{software} %{version}",
  copy_download = "Pobierz z %{github}",

  --==[[ Forms ]]==--

  form_ban                 = "Zbanuj użytkownika",
  form_ban_display         = "Wyświetl bana",
  form_ban_board           = "Ban lokalny",
  form_ban_reason          = "Powód bana",
  form_ban_time            = "Długość bana (w minutach)",
  form_clear               = "Wyczyść",
  form_delete              = "Usuń posta",
  form_draw                = "Rysuj",
  form_lock                = "Zablokuj wątek",
  form_override            = "Nielimitowane pliki",
  form_readme              = "Przeczytaj [%{rules}] oraz [%{faq}] zanim zapostujesz.",
  form_remix               = "Przerób obrazek",
  form_report              = "Zgłoś posta",
  form_required            = "pole wymagane",
  form_save                = "Zapisz wątek",
  form_sticky              = "Przyklej freda",
  form_submit              = "Wyślij posta",
  form_submit_name         = "Pseudonim",
  form_submit_name_help    = "Nadaj sobie nazwę lub tripkod (opcjonalne)",
  form_submit_subject      = "Temat",
  form_submit_subject_help = "Temat dyskusji (opcjonalne)",
  form_submit_options      = "Opcje",
  form_submit_options_help = "sage: zapostuj bez podbijania freda (opcjonalne)",
  form_submit_comment      = "Komentarz",
  form_submit_comment_help = "Dodaj coś do dyskusji",
  form_submit_file         = "Plik",
  form_submit_file_help    = "Załącz plik",
  form_submit_draw         = "Rysuj",
  form_submit_draw_help    = "Narysuj lub przerób obrazek",
  form_submit_spoiler      = "Spoiler",
  form_submit_spoiler_help = "Podmień miniaturkę na spoiler",
  form_submit_mod          = "Moderator",
  form_submit_mod_help     = "Oznacz tego freda",
  form_width               = "Szerokość",
  form_height              = "Wysokość",

  --==[[ Posts ]]==--

  post_link     = "Link do tego posta",
  post_lock     = "Wątek jest zablokowany",
  post_hidden   = "%{n_post} %{p_post} i %{n_file} %{p_file} zostały pominięte. %{click} aby wyświetliść.",
  post_override = "Wątek akceptuje nielimitowaną ilość plików",
  post_reply    = "Odpowiedz na ten post",
  post_sticky   = "Fred jest przyklejony",
  post_save     = "Wątek nie będzie archiwizowany",

  --==[[ Plurals ]]==--

  days = {
    one   = "dzień",
    other = "days"
  },
  files = {
    one   = "plik",
    few   = "pliki",
    many  = "plików"
  },
  posts = {
    one   = "post",
    few   = "posty",
    many  = "postów"
  },
  threads = {
    one   = "wątek",
    few   = "wątki",
    many  = "wątków"
  },
}}
