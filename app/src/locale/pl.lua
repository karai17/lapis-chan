return { pl = {

  --==[[ Navigation ]]==--

  archive       = "Archiwum",
  bottom        = "Przewiń na dół",
  catalog       = "Katalog",
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
  admin_panel             = "Panel cwela",
  administrator           = "Cwel",
  announcement            = "Ogłoszenie",
  archive_days            = "Dni do archiwizowania wątków",
  archive_pruned          = "Archiwizuj wątki",
  board                   = "Board",
  board_group             = "Grupa boarda",
  board_name              = "Nazwa boarda",
  bump_limit              = "Limit przyjebek",
  content_md              = "Opis (Markdown)",
  default_name            = "Domyślna nazwa",
  draw_board              = "Board do rysowania",
  file                    = "Plik",
  file_limit              = "Limit plików w wątku",
  global                  = "Globalnie",
  index_boards            = "Aktualne boardy",
  janitor                 = "Woźny",
  login                   = "Zaloguj",
  logout                  = "Wyloguj",
  moderator               = "Moderator",
  name                    = "Nazwa",
  num_pages               = "Aktywne strony",
  num_threads             = "Fredy na stronę",
  password                = "Hasło",
  password_old            = "Powtórz hasło",
  password_retype         = "Stare hasło",
  post_comment_required   = "Wymagany komentarz do posta",
  post_file_required      = "Wymagany plik do posta",
  regen_thumb             = "Odśwież miniaturki",
  reply                   = "Odpowiedz",
  rules                   = "Zasady",
  short_name              = "Krótka nazwa",
  subtext                 = "Podtekst",
  success                 = "Sukces",
  text_board              = "Board tekstowy",
  theme                   = "Motyw",
  thread_comment_required = "Wymagany komentarz do freda",
  thread_file_required    = "Wymagany plik do freda",
  url                     = "URL",
  username                = "Nazwa użytkownika",
  yes                     = "Tak",
  no                      = "Nie",

  -- Announcements
  create_ann   = "Utwórz ogłoszenie",
  modify_ann   = "Zmień ogłoszenie",
  delete_ann   = "Wyjeb ogłoszenie",
  created_ann  = "Utworzyłeś ogłoszenie %s.",
  modified_ann = "Zmieniłeś ogłoszenie %s.",
  deleted_ann  = "Wyjebałeś ogłoszenie %s.",

  -- Boards
  create_board   = "Utwórz boarda",
  modify_board   = "Zmień boarda",
  delete_board   = "Wyjeb boarda",
  created_board  = "Utworzyłeś boarda /%s/ - %s.",
  modified_board = "Zmieniłeś boarda /%s/ - %s.",
  deleted_board  = "Wyjebałeś boarda /%s/ - %s.",

  -- Pages
  create_page   = "Utwórz stronę",
  modify_page   = "Zmień stronę",
  delete_page   = "Wyjeb stronę",
  created_page  = "Utworzyłeś stronę /%s/ - %s.",
  modified_page = "Zmieniłeś stronę /%s/ - %s.",
  deleted_page  = "Wyjebałeś stronę /%s/ - %s.",

  -- Reports
  view_report    = "Przejrzyj zgłoszenie",
  delete_report  = "Usuń zgłoszenie",
  deleted_report = "Wyjebałeś zgłoszenie %s.",

  -- Users
  create_user   = "Utwórz użytkownika",
  modify_user   = "Zmień użytkownika",
  delete_user   = "Wyjeb użytkownika",
  created_user  = "Utworzyłeś użytkownika %s.",
  modified_user = "Zmieniłeś użytkownika %s.",
  deleted_user  = "Wyjebałeś użytkownika %s.",

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
  post_hidden   = "%{n_post} %{p_post} i %{n_file} %{p_file} zostały pominięte. %{click} aby wyświetlić.",
  post_override = "Wątek akceptuje nielimitowaną ilość plików",
  post_reply    = "Odpowiedz na ten post",
  post_sticky   = "Fred jest przyklejony",
  post_save     = "Wątek nie będzie archiwizowany",

  --==[[ Plurals ]]==--

  days = {
    one   = "dzień",
    other = "dni"
  },
  files = {
    one   = "plik",
    few   = "pliki",
    many  = "plików",
	 other = "pliki"
  },
  posts = {
    one   = "post",
    few   = "posty",
    many  = "postów",
	 other = "posty"
  },
  threads = {
    one   = "wątek",
    few   = "wątki",
    many  = "wątków",
	 other = "wątki"
  },
}}
