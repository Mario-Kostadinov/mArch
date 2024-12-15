(require 'use-package)
  (setq use-package-always-ensure t)

  (require 'package)

  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))

  (package-initialize)
  (unless package-archive-contents
   (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
  (unless (package-installed-p 'use-package)
     (package-install 'use-package))

  (unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))

  (quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)

(setq make-backup-files nil)

(tool-bar-mode -1)
(menu-bar-mode -1)			
(scroll-bar-mode -1)
(set-fringe-mode 5)

(set-face-attribute 'default nil :height 260)
;;(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 295 :weight 'regular)

(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda() (display-line-numbers-mode 0))))

(use-package projectile
   :ensure t
   :init
   (projectile-mode +1)
   :bind (:map projectile-mode-map
            ("s-p" . projectile-command-map)
            ("C-c p" . projectile-command-map)))

(setq projectile-project-search-path '("~/mos" "~/Work"))

(use-package counsel-projectile
  :ensure t
  :after (projectile)
  :config
  (counsel-projectile-mode 1))

(use-package all-the-icons)
;; After this we need to the M-x all-the-icons-install-fonts

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-acario-dark t)
  (doom-themes-org-config)
  )

(use-package doom-modeline
	  :ensure t
	  :init (doom-modeline-mode 1)

      (setq doom-modeline-height 25)
      (setq doom-modeline-bar-width 5)
(setq doom-modeline-icon t)
(setq doom-modeline-major-mode-icon t)
(setq doom-modeline-buffer-state-icon t)
(setq doom-modeline-major-mode-color-icon t)
(setq doom-modeline-lsp-icon t)
(setq doom-modeline-buffer-name t)
(setq doom-modeline-minor-modes t)
(setq doom-modeline-total-line-number t)

      )

(setq org-directory "~/mos/notes")
(setq org-treat-insert-todo-heading-as-state-change t)

(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-log-into-drawer t)
(setq org-agenda-span 14)
(setq org-todo-keywords
      '((sequence "TODO" "IN-PROGRESS" "WAITING" "|" "DONE" "CANCELLED")))
(setq org-agenda-custom-commands
      '(("p" "Projects" tags-todo "+project")
        ("mt" "This month view"
         ((agenda "" 
                  ((org-agenda-span 'month)  ;; Set the agenda span to one month
                   (org-agenda-start-day (format-time-string "%Y-%m-01")
                                         (org-agenda-start-on-weekday nil)  ;; Don't force the start day to be Monday
                                         ))))
         )
        ("mp" "Previous Month"
         ((agenda ""
                  ((org-agenda-span 'month)
                   (org-agenda-start-day (format-time-string "%Y-%m-01" (time-subtract (current-time) (days-to-time 30))))
                   (org-agenda-show-all-dates t)
                   (org-agenda-start-on-weekday nil)))))

        ("mn" "Next Month"
         ((agenda ""
                  ((org-agenda-span 'month)
                   (org-agenda-start-day (format-time-string "%Y-%m-01"
                                                             (time-add (current-time) (days-to-time 30))))
                   (org-agenda-show-all-dates t)
                   (org-agenda-start-on-weekday nil)))))
        ))

(use-package org
  :hook (org-mode . efs/org-mode-setup))

(setq org-ellipsis " ▾")

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  )

(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))

(use-package visual-fill-column
    :config
      (setq-default visual-fill-column-width 150)
      (setq-default visual-fill-column-center-text t  )
    )




(add-hook 'visual-line-mode-hook #'visual-fill-column-mode)

;; Make sure org-indent face is available
(require 'org-indent)

;; Increase the size of various headings
(set-face-attribute 'org-document-title nil :font "Cantarell" :weight 'bold :height 1.3)

(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Cantarell" :weight 'medium :height (cdr face)))

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Get rid of the background on column views
(set-face-attribute 'org-column nil :background nil)
(set-face-attribute 'org-column-title nil :background nil)

(use-package org-bullets
:after org
:hook (org-mode . org-bullets-mode)
:custom
(org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp .t)))

(setq org-confirm-babel-evaluate nil)

(defun calculate-org-progress ()
  "Calculate the overall progression percentage for TODO and DONE entries in the current Org buffer."
  (interactive)
  (let ((total-tasks 0)
        (completed-tasks 0))
    ;; Count all TODO and DONE entries in the buffer
    (org-map-entries
     (lambda ()
       (setq total-tasks (1+ total-tasks))
       (when (string= (org-get-todo-state) "DONE")
         (setq completed-tasks (1+ completed-tasks)))))
    ;; Calculate the percentage
    (let ((progress (if (> total-tasks 0)
                        (* 100 (/ (float completed-tasks) total-tasks))
                      0)))
      (message "Total Progression: %.2f%% (%d/%d completed)"
               progress completed-tasks total-tasks)
      progress)))

(use-package org-roam
  :ensure t
  :bind(("C-c n l" . org-roam-buffer-toggle)
        ("C-c n f" . org-roam-node-find)
        ("C-c n i" . org-roam-node-insert)
        ("C-c d c" . org-roam-dailies-capture-today)
        ("C-c d s" . org-roam-dailies-goto-today)
        )
  :config
  ;;(setq org-roam-db-autosync-mode t)
  (setq org-roam-directory "~/mos/notes/OrgRoam")
  )

;;(use-package ripgrep)
;;(use-package rg.el)

(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
         (file+head "${slug}.org" "#+title: ${title}")
         :unnarrowed t)

        ("p" "Project" plain "%?"
         :target (file+head "~/mos/notes/OrgRoam/projects/${slug}.org"
                            "#+title: ${title}\n#+category: ${title}\n#+filetags: project ${slug}\n* Overview\n- Start date: %U\n- Current status: \n\n* Tasks\n\n* Milestones\n")
         :unnarrowed t)
        ("r" "Recipes" plain "%?"
         :if-new (file+head "~/mos/notes/recipes/${slug}.org"
                            "#+title: ${title}\n#+filetags: recipes\n#+date: %U\n\n* Ingredients\n\n* Instructions")
         :unnarrowed t)
        ))

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry "* %?"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>" ("Inbox"))
         :unnarrowed t)

        ("t" "Todo")

        ("tt" "Todo" entry "* TODO %^{What do you want to do?}"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>"
                                ("Tasks"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)

        ("ts" "Scheduled TODO" entry "* TODO %^{What do you want to do?}\nSCHEDULED: %^t"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>"
                                ("Tasks"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)
        ("l" "Website" entry "* [[%^{URL}][%^{Description}]]\n:PROPERTIES:\n:WEBSITE: yes\n:WEBSITE_TYPE: %^{Type of website|blog|documentation|tutorial|article|reference|ecommerce}\n:END:\nCaptured on %U"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Websites"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)


        ("r" "Reminder" entry "* %^{Reminder} %^T"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Reminders"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)
        ("j" "Journal" entry "* %^{Journal: }\n:LOGBOOK:\nCLOCK: %U\n:END:"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Journal"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)

        ("w" "Work Entry" entry "* %^{What did you do?}\n:LOGBOOK:\nCLOCK: %U\n:END:"
         :target (file+head+olp "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"
                                ("Work"))
         :unnarrowed t
         :empty-lines-before 1
         :prepend t
         :immediate-finish t)))

(use-package org-ql
          :quelpa (org-ql :fetcher github :repo "alphapapa/org-ql"
                    :files (:defaults (:exclude "helm-org-ql.el")))
          :config
        ;; Define a custom function to search for TODO tasks
        (defun my-org-ql-search-todo ()
          "Search for TODO tasks across all agenda files."
          (interactive)
          (org-ql-search
            (org-agenda-files)  ;; Search all agenda files
            '(todo "TODO")       ;; Query for TODO items
            :title "TODO Items"  ;; Title for the results buffer
            :super-groups '((:name "Tasks" :todo t))  ;; Group results by TODO states
            :sort '(priority date)))
      (defun my-org-ql-search-done-tasks ()
        "Search for DONE tasks ordered by CLOSED date."
        (interactive)
        (org-ql-search
          (org-agenda-files)
          '(and (todo "DONE") (closed))
          :title "Completed Tasks"
          :sort '(closed)))

          )

    (defun my/org-ql-search-in-agenda-by-tag ()
      "Prompt for a tag and search for it in `org-agenda-files`."
      (interactive)
      (let ((tag (completing-read "Tag: " org-tag-alist)))
        (org-ql-search org-agenda-files
          `(tags ,tag)
          :title (format "Notes with tag: %s" tag))))

  

(defun my/org-ql-search-websites ()
  "Search for entries marked as websites in `org-agenda-files`."
  (interactive)
  (org-ql-search org-agenda-files
    '(property "WEBSITE" "yes")
    :title "Entries marked as Websites"))


(defun search-org-websites-without-ql (&optional website-type)
  "Search Org notes for entries with the property WEBSITE set to 'yes'. Optionally filter by WEBSITE_TYPE."
  (interactive "sEnter website type (leave blank for all): ")
  (let ((search-string (if (string-empty-p website-type)
                           "+WEBSITE={yes}"
                         (format "+WEBSITE={yes} +WEBSITE_TYPE={%s}" website-type))))
    (org-map-entries
     (lambda ()
       (let ((title (org-get-heading t t t t))
             (type (org-entry-get nil "WEBSITE_TYPE")))
         (message "%s | %s" title (or type "No type"))))
     search-string
     'file)))


  (defun my/org-ql-search-all-agenda-files ()
    "Prompt for a search string and search for it in all `org-agenda-files`."
    (interactive)
    (let ((search-term (read-string "Search for: ")))
      (org-ql-search org-agenda-files
        `(regexp ,search-term)
        :title (format "Search results for: %s" search-term)


        )))

(setq org-agenda-files (directory-files-recursively "~/mos/notes" "\\.org$"))

(add-hook 'after-save-hook
        (lambda ()
          (when (string= (file-name-extension buffer-file-name) "org")
            (setq org-agenda-files (directory-files-recursively "~/mos/notes""\\.org$")))))

;;(setq org-agenda-files '("~/mos/notes"))

(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (setq select-enable-clipboard t)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
)

(use-package ivy
  :bind(
        :map ivy-minibuffer-map
             ("TAB" . ivy-alt-done)
             ("C-l" . ivy-alt-done)
             ("C-j" . ivy-next-line)
             ("C-k" . ivy-previous-line)
        :map ivy-switch-buffer-map
             ("C-k" . ivy-previous-line)
             ("C-l" . ivy-done)
             ("C-d" . ivy-switch-buffer-kill)
        ))

(ivy-mode 1)

;; TODO - not yet sure what these do
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

(use-package ivy-rich)

(use-package which-key
  :config
   (setq which-key-popup-type 'minibuffer)
   (setq which-key-idle-delay 3))
(which-key-mode 1)

(global-set-key "\C-s" 'swiper)
(global-set-key "\C-\M-j" 'counsel-switch-buffer)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c q t") 'my/org-ql-search-in-agenda-by-tag)
(global-set-key (kbd "C-c q s") 'counsel-rg)
(global-set-key (kbd "C-c q w") 'my/org-ql-search-websites)

;;(global-set-key (kbd "<escape>" 'keyboard-escape-quit))
