return { fr = {

	--==[[ Navigation ]]==--

	archive       = "Archive",
	bottom        = "Bas",
	catalog       = "Catalogue",
	index         = "Index",
	refresh       = "Rafraîchir",
	["return"]    = "Retourner",
	return_board  = "Retourner au babillard",
	return_index  = "Retourner à l'index",
	return_thread = "Retourner au fil de discussion",
	top           = "Haut",

	--==[[ Error Messages ]]==--

	-- Controller error messages
	err_ban_reason = "Aucune Reçue.",
	err_board_used = "Le nom du Babillard est déjà utilisé.",
	err_not_admin  = "Vous n'êtes pas un administrateur.",
	err_orphaned   = "Le Fil de Discussion nº%s est orphelin.",
	err_slug_used  = "Le slug de la page est déjà utilisée.",
	err_user_used  = "Le nom d'utilisateur est dèja utilisé.",

	-- Model error messages
	err_contribute     = "Vous devez poster un commentaire ou un fichier.",
	err_locked_thread  = "Le fil de discussion No.%s est verrouillé.",
	err_no_files       = "Les fichiers ne sont pas acceptés sur ce babillard.",

	err_comment_post   = "Un commentaire est requis pour poster sur ce babillard.",
	err_comment_thread = "Un commentaire est requis pour poster un fil de discussion sur ce babillard.",

	err_create_ann     = "Impossible de créer un annoncement: %s.",
	err_create_ban     = "Impossible de bannir l'IP: %s.",
	err_create_board   = "Impossible de créer le babillard: /%s/ - %s.",
	err_create_page    = "Impossible de créer la page: /%s/ - %s.",
	err_create_post    = "Impossible de soumettre le poste.",
	err_create_report  = "Impossible de reporter le post No.%s.",
	err_create_thread  = "Impossible de créer un nouveau fil de discussion.",

	err_delete_board   = "Impossible de supprimer le babillard: /%s/ - %s.",
	err_delete_post    = "Impossible de supprimer le poste No.%s.",
	err_create_user    = "Impossible de créer l'utilisateur: %s.",

	err_file_exists    = "Le fichier existe déjà sur ce babillard.",
	err_file_limit     = "Le fil de discussion No.%s a atteint sa limite de fichier.",
	err_file_post      = "Un fichier est requis pour poster sur ce babillard.",
	err_file_thread    = "Un fichier est requis pour poster un fil de discussion sur ce babillard.",

	err_invalid_board  = "Babillard invalide: /%s/.",
	err_invalid_ext    = "Type de fichier invalide: %s.",
	err_invalid_image  = "Données d'image invalides.",
	err_invalid_post   = "Le poste No.%s n'est pas valide.",
	err_invalid_user   = "Nom d'utilisateur ou mot de passe invalide.",

	--==[[ 404 ]]==--

	["404"] = "404 - Page Introuvable",

	--==[[ Administration ]]==--

	-- General
	admin_panel             = "Panneau Administratif",
	administrator           = "Administrateur",
	announcement            = "Annoncement",
	archive_days            = "Nombre de jours à garder les Fils de Discussion dans l'Archive",
	archive_pruned          = "Archiver les Fils de Discussion Réduites",
	board                   = "Babillard",
	board_group             = "Group de babillard",
	board_title             = "Nom de Babillard",
	bump_limit              = "Limite pour remonter un fil de discussion",
	content_md              = "Contenu (Markdown)",
	default_name            = "Nom par Défaut",
	draw_board              = "Babillard à Dessin",
	file                    = "Fichier",
	file_limit              = "Limite de fichiers dans un Fil de Discussion",
	global                  = "Global",
	index_boards            = "Babillards Présent",
	janitor                 = "Concierge",
	login                   = "Connexion",
	logout                  = "Déconnexion",
	moderator               = "Modérateur",
	num_pages               = "Pages Actives",
	num_threads             = "Fils de Discussion par Page",
	password                = "Mot de Passe",
	password_old            = "Ancient Mot de Passe",
	password_retype         = "Confirmer le Mot de Passe",
	post_comment_required   = "Exiger un commentaire pour pouvoir poster",
	post_file_required      = "Exiger un Fichier pour pouvoir poster",
	regen_thumb             = "Régénérer les Miniatures",
	reply                   = "Répondre",
	rules                   = "Les Règles",
	name                    = "Nom",
	subtext                 = "Sous-texte",
	success                 = "Succès",
	text_board              = "Babillard à Texte",
	theme                   = "Thème",
	thread_comment_required = "Exiger un Commentaire ",
	thread_file_required    = "Exiger un Fil de Discussion",
	slug                    = "Slug",
	username                = "Nom d'utilisateur",
	yes                     = "Oui",
	no                      = "Non",

	-- Announcements
	create_ann   = "Créer un Annoncement",
	modify_ann   = "Modifier un Annoncement",
	delete_ann   = "Supprimer un Annoncement",
	created_ann  = "Création de l'annoncement: %s réussie.",
	modified_ann = "Modification de l'annoncement: %s réussie.",
	deleted_ann  = "Suppression de l'annoncement: %s réussie.",

	-- Boards
	create_board   = "Créer un Babillard",
	modify_board   = "Modifier un Babillard",
	delete_board   = "Supprimer un Babillard",
	created_board  = "Création du Babillard: /%s/ - %s réussie.",
	modified_board = "Modification du Babillard : /%s/ - %s réussie.",
	deleted_board  = "Suppression du Babillard : /%s/ - %s réussie.",

	-- Pages
	create_page   = "Créer une Page",
	modify_page   = "Modifier une Page",
	delete_page   = "Supprimer une Page",
	created_page  = "Création de la page : /%s/ - %s réussie.",
	modified_page = "Modification de la page : /%s/ - %s réussie.",
	deleted_page  = "Suppression de la page : /%s/ - %s réussie.",

	-- Reports
	view_report    = "Afficher un Rapport",
	delete_report  = "Supprimer un Rapport",
	deleted_report = "Suppression du Rapport: %s réussie.",

	-- Users
	create_user   = "Créer un Utilisateur",
	modify_user   = "Modifier un Utilisateur",
	delete_user   = "Supprimer un Utilisateur",
	created_user  = "Création de l'utilisateur: %s réussie.",
	modified_user = "Modification de l'utilisateur: %s réussie.",
	deleted_user  = "Suppression de l'utilisateur: %s réussie.",

	--==[[ Archive ]]==--

	arc_display = "Affichage de %{n_thread} %{p_thread} expirés depuis %{n_day} %{p_day} ",
	arc_number  = "nº",
	arc_name    = "Nom",
	arc_excerpt = "Extrait",
	arc_replies = "Réponses",
	arc_view    = "Afficher",

	--==[[ Ban ]]==--

	ban_title  = "Banni!",
	ban_reason = "Vous avez été banni pour la raison suivante:",
	ban_expire = "Votre ban expirera le %{expire}.",
	ban_ip     = "Selon avec notre serveur, votre IP est: %{ip}.",

	--==[[ Catalog ]]==--

	cat_stats = "R: %{replies} / F: %{files}",

	--==[[ Copyright ]]==--

	copy_software = "Réalisé avec %{software} %{version}",
	copy_download = "Télécharger à partir de %{github}",

	--==[[ Forms ]]==--

	form_ban                 = "Bannir l'Utilisateur",
	form_ban_display         = "Afficher le Ban",
	form_ban_board           = "Ban Local",
	form_ban_reason          = "Raison du ban",
	form_ban_time            = "Durée (en jours) à bannir l'utilisateur",
	form_clear               = "Effacer",
	form_delete              = "Supprimer le Poste",
	form_draw                = "Dessiner",
	form_lock                = "Verrouiller le Fil de Discussion",
	form_override            = "Fichiers Illimités",
	form_readme              = "Veuillez lire [%{rules}] et la  [%{faq}] avant de poster.",
	form_remix               = "Remixer l'Image",
	form_report              = "Reporter le Poste",
	form_required            = "Champ Requis",
	form_save                = "Épargner le Fil de Discussion",
	form_sticky              = "Épingler le Fil de Discussion",
	form_submit              = "Soumettre le Poste",
	form_submit_name         = "Nom",
	form_submit_name_help    = "Donnez-vous un nom , un tripcode ou les deux (facultatif)",
	form_submit_subject      = "Sujet",
	form_submit_subject_help = "Définir le sujet de la discussion (facultatif)",
	form_submit_options      = "Options",
	form_submit_options_help = "Sage: poster sans faire monter le fil de discussion (À venir) (facultatif)",
	form_submit_comment      = "Commentaire",
	form_submit_comment_help = "Contribuer à la discussion (ou non)",
	form_submit_file         = "Fichier",
	form_submit_file_help    = "Télécharger un fichier",
	form_submit_draw         = "Dessiner",
	form_submit_draw_help    = "Dessiner ou remixer une image",
	form_submit_spoiler      = "Spoiler",
	form_submit_spoiler_help = "Replacer la miniature avec une image sans spoiler",
	form_submit_mod          = "Modérateur",
	form_submit_mod_help     = "Mettre un drapeau sur ce fil de discussion",
	form_width               = "Largeur",
	form_height              = "Hauteur",

	--==[[ Posts ]]==--

	post_link     = "Lier à ce poste",
	post_lock     = "Le fil de discussion est verrouillé",
	post_hidden   = "%{n_post} %{p_post} et %{n_file} %{p_file} omis. %{click} pour afficher.",
	post_override = "Ce fil de discussion accepte un nombre illimité de fichiers",
	post_reply    = "Répondre à ce poste",
	post_sticky   = "Le fil de discussion est épinglé",
	post_save     = "Le fil de discussion ne sera pas enlevé automatiquement",

	--==[[ Plurals ]]==--

	days = {
		one   = "jour",
		other = "jours"
	},
	files = {
		one   = "fichier",
		other = "fichiers"
	},
	posts = {
		one   = "poste",
		other = "postes"
	},
	threads = {
		one   = "fil de discussion",
		other = "fils de discussion"
	},
}}
