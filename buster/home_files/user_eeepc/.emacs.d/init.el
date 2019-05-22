;; general layout
;; ==============

;; need no stinkin emacs help screen as start up, and no menu bar
(setq inhibit-startup-screen t)
(menu-bar-mode -1)

;; highlight cursor line, parentheses
(global-hl-line-mode 1)
(show-paren-mode 1)

;; show line numbers, use separator space
(global-linum-mode)
(setq linum-format "%d ")

;; count cursor column, row in mode line
(setq column-number-mode t)

;; settings to make GUI tolerable
(if window-system
  (progn
    (add-to-list 'default-frame-alist '(foreground-color . "white"))
    (add-to-list 'default-frame-alist '(background-color . "black"))
    (set-face-attribute 'default nil :height 80)
    (scroll-bar-mode -1)
    (setq visible-bell t)
    (setq linum-format "%d")))

;; use as default browser what XDG offers
(setq-default browse-url-browser-function 'browse-url-xdg-open)

;; general keybindings
;; ===================

;; create and use a minimal global map using just the self-insert command
;; bindings and a selection of some to me very common keystrokes
(setq minimal-map (make-sparse-keymap))
(substitute-key-definition 'self-insert-command 'self-insert-command
                           minimal-map global-map)
(use-global-map minimal-map)
(global-set-key (kbd "DEL") 'backward-delete-char-untabify)
(global-set-key (kbd "RET") 'newline)
(global-set-key (kbd "TAB") 'indent-for-tab-command)
(global-set-key (kbd "<up>") 'previous-line)
(global-set-key (kbd "<down>") 'next-line)
(global-set-key (kbd "<left>") 'left-char)
(global-set-key (kbd "<right>") 'right-char)
(global-set-key (kbd "<prior>") 'scroll-down-command)
(global-set-key (kbd "<next>") 'scroll-up-command)
(global-set-key (kbd "M-x") 'execute-extended-command)
(global-set-key (kbd "C-g") 'keyboard-quit)
;(global-set-key (kbd "<f3>") 'kmacro-start-macro-or-insert-counter)
;(global-set-key (kbd "<f4>") 'kmacro-end-or-call-macro)
;; note how to switch back to the original map: (use-global-map global-map)
(setq shr-map (make-sparse-keymap))  ; got annoying in elfeed-show on URLs


;; minibuffer
;; ==========

;; incremental minibuffer completion
(icomplete-mode 1)



;; text editing
;; ============

;; tabs are evil
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; show trailing whitespace
(setq-default show-trailing-whitespace 1)

;; on save, ask whether to ensure text file's last line ends in a
;; newline character
(setq require-final-newline 1)

;; use dedicated directory for version-controlled, endless backups;
;; never delete old versions
(setq make-backup-files t
      backup-directory-alist `(("." . "~/.emacs_backups"))
      backup-by-copying t
      version-control t
      delete-old-versions 1)  ;; neither t nor nil: never delete



;; package management
;; ==================

;; where we get packages from
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa-unstable" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))

;; ensure certain packages are installed (actually, we use Debian repos here)
;; credit to <https://stackoverflow.com/a/10093312>
;(setq package-list '(elfeed ledger-mode))
;(package-initialize)
;(dolist (package package-list)
;  (unless (package-installed-p package)
;    (package-install package)))



;;; window management
;;; =================
;
;;; track window configurations to allow window config undo
;(winner-mode 1)



;; mail setup
;; ==========

(setq send-mail-function 'smtpmail-send-it)
(setq smtpmail-smtp-server "core.plomlompom.com")
(setq smtpmail-smtp-service 465)
(setq smtpmail-stream-type 'ssl)
(setq smtpmail-smtp-user "plom")
(setq mml-secure-openpgp-encrypt-to-self t)

;; constructs From: domain if mail composer directly called (from without
;; notmuch), but we don't actually intend to do that
;(setq mail-host-address "plomlompom.com")

;; otherwise notmuch becomes extremely slow in some cases
(setq-default notmuch-show-indent-content nil)

;; this only works if we use notmuch-mua-send instead of message-send
(setq notmuch-fcc-dirs '(("plom@plomlompom.com" . "maildir/Sent")))


;; org mode
;; ========

;; unsure why, but to re-set the key map, we not only have to explicitely do it
;; only after org-mode loading, but also have to explicitely overwrite the
;; C-c keybinding; TODO: investigate
(with-eval-after-load 'org
    (setq org-mode-map (make-sparse-keymap))
    (define-key org-mode-map (kbd "C-c") nil)
    (define-key org-mode-map (kbd "TAB") 'org-cycle)
    (define-key org-mode-map (kbd "<backtab>") 'org-shifttab))

;; basic org-capture config
(setq org-capture-templates
      '(("x" "test" plain (file "~/org/notes.org") "%T: %?")))
(add-hook 'org-capture-mode-hook 'evil-insert-state)

;; agenda view on startup
(load-library "find-lisp")
(setq org-agenda-files (find-lisp-find-files "~/org" "\.org$"))
(setq org-agenda-span 90)
(setq org-agenda-use-time-grid nil)
(add-hook 'emacs-startup-hook (lambda ()
                                 (org-agenda-list)
                                 (switch-to-buffer "*Org Agenda*")
                                 (other-window 1)))

;;; for calendar, use ISO date style
;(setq calendar-date-style 'iso)
;(setq diary-number-of-entries 7)
;(diary)
;(setq org-agenda-time-grid '((today require-timed remove-match)
;                             #("----------------" 0 16 (org-heading t))
;                             (0 200 400 600 800 1000 1200
;                                1400 1600 1800 2000 2200)))

;; empty org-agenda-mode keybindings
(add-hook 'org-agenda-mode-hook
          (lambda ()
            (setq org-agenda-mode-map (make-sparse-keymap))))
(add-hook 'org-agenda-mode-hook
          (lambda ()
            (use-local-map (make-sparse-keymap))))

;; org-publish-all
(setq org-publish-project-alist
      '(
        ("website"
         :base-directory "~/org/web/"
         :base-extension "org"
         :publishing-directory "~/html/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4             ; Just the default for this project.
         :auto-preamble t
          )))

;; use [ki:] syntax to hide stuff from exports
(defun classify-information (text backend info)
  "Replaces '[ki:WHATEVER]' with '[klassifizierte Information]'."
  (replace-regexp-in-string "\\[ki:[^\]]*\]" "[klassifizierte Information]" text))
(add-hook 'org-export-filter-plain-text-functions 'classify-information)

;; add HTML validator link to exports
(setq org-html-validation-link "<a href=\"https://validator.w3.org/check?uri=referer\">Validate</a>")



;;; plomvi mode
;;; ===========
(load "~/public_repos/plomvi.el/plomvi.el")
(global-set-key (kbd "C-c") 'plomvi-activate)
(plomvi-global-mode 1)



;;; Info mode
;;; =========

(setq Info-mode-map (make-sparse-keymap))
(define-key Info-mode-map (kbd "RET") 'Info-follow-nearest-node)
(define-key Info-mode-map (kbd "u") 'Info-up)
(define-key Info-mode-map (kbd "TAB") 'Info-next-reference)
(define-key Info-mode-map (kbd "<backtab>") 'Info-prev-reference)
(define-key Info-mode-map (kbd "H") 'Info-history-back)
(define-key Info-mode-map (kbd "L") 'Info-history-forward)
(define-key Info-mode-map (kbd "I") 'Info-goto-node)
(define-key Info-mode-map (kbd "i") 'Info-index)

;; help mode
;; =========

(setq help-mode-map (make-sparse-keymap))
(define-key help-mode-map (kbd "TAB") 'forward-button)
(define-key help-mode-map (kbd "RET") 'help-follow)
(define-key help-mode-map (kbd "<backtab>") 'backward-button)

;; elfeed
;; ======

(require 'elfeed)  ; needed so we can set the font faces
(set-face-background 'elfeed-search-title-face "magenta")
(set-face-background 'elfeed-search-unread-count-face "magenta")
(setq elfeed-feeds
      '("https://capsurvival.blogspot.com/feeds/posts/default"
        "https://jungle.world/rss.xml"
        "http://news.dieweltistgarnichtso.net/bin/index.xml"
        "https://taz.de/!s=&ExportStatus=Intern&SuchRahmen=Online;rss/"
        "http://www.tagesschau.de/xml/atom"))
(setq elfeed-search-mode-map (make-sparse-keymap))
(define-key elfeed-search-mode-map (kbd "RET") 'elfeed-search-show-entry)
(defun elfeed-search-mark-as-read() (interactive)
  (elfeed-search-untag-all 'unread))
(define-key elfeed-search-mode-map (kbd "r") 'elfeed-search-mark-as-read)
(define-key elfeed-search-mode-map (kbd "R") 'elfeed-search-tag-all-unread)
(define-key elfeed-search-mode-map (kbd "f") 'elfeed-search-live-filter)
(define-key elfeed-search-mode-map (kbd "u") 'elfeed-update)
(setq elfeed-show-mode-map (make-sparse-keymap))
(define-key elfeed-show-mode-map (kbd "u") 'elfeed)
(define-key elfeed-show-mode-map (kbd "TAB") 'shr-next-link)
(define-key elfeed-show-mode-map (kbd "<backtab>") 'shr-previous-link)
(define-key elfeed-show-mode-map (kbd "a") 'elfeed-show-prev)
(define-key elfeed-show-mode-map (kbd "d") 'elfeed-show-next)
(define-key elfeed-show-mode-map (kbd "y") 'shr-copy-url)
(define-key elfeed-show-mode-map (kbd "RET") 'shr-browse-url)

;; eww
;; ===

(setq eww-mode-map (make-sparse-keymap))
(define-key eww-mode-map (kbd "TAB") 'shr-next-link)
(define-key eww-mode-map (kbd "<backtab>") 'shr-previous-link)
(define-key eww-mode-map (kbd "H") 'eww-back-url)
(define-key eww-mode-map (kbd "L") 'eww-forward-url)

;; ledger
;; ======
(setq ledger-mode-map (make-sparse-keymap))
(define-key ledger-mode-map (kbd "TAB") 'ledger-magic-tab)


;; unset other maps so they don't disturb C-c keybinding
;; =====================================================
;; TODO: saner solution would be a default-activated minor mode that binds
;; C-c
(setq conf-mode-map (make-sparse-keymap))
(setq sh-mode-map (make-sparse-keymap))
(setq python-mode-map (make-sparse-keymap))
