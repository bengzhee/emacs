(let ((proxy "ocbcpnet.ocbc.local:8080") (credentials "OCBCGROUP\\A5124832:QWEqwe123"))  (setq url-proxy-services `(("no_proxy" . "^\\(localhost\\|10.*\\)")   ("http" . ,proxy)   ("https" . ,proxy)))  (setq url-http-proxy-basic-auth-storage (list (list proxy      (cons "username"     (base64-encode-string credentials))))))
(server-start)

;; Add repository
(when (>= emacs-major-version 25)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it's not.
   
   Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     ;; (package-installed-p 'evil)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; make sure to have downloaded archive description.
;; Or use package-archive-contents as suggested by Nicolas Dudebout
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(ensure-package-installed 'magit
                          'js2-mode
                          'web-beautify
                          'projectile
                          'auto-complete
                          'anzu
                          'omnisharp
                          'py-autopep8
                          'flycheck
                          'smex
                          'elpy
                          'ivy
                          'neotree
                          'swiper
                          'counsel
                          'multiple-cursors
			  'fill-column-indicator)

;; activate installed packages
(package-initialize)

;; Load theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/moe-theme")
(load-theme 'moe-dark t)

;; Load custom lisp scripts
(let ((default-directory "~/.emacs.d/lisp/"))
  (normal-top-level-add-to-load-path '("."))
  (normal-top-level-add-subdirs-to-load-path))

;; Disable bars
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Show column numbers
(setq column-number-mode t)

;; Don't show startup screen
(setq inhibit-startup-screen t)

;; Maximize on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; M-o for buffer window switch
(global-set-key (kbd "M-o") 'other-window)

;; Saving config
(setq backup-directory-alist
`((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
`((".*" ,temporary-file-directory t)))
(setq delete-by-moving-to-trash t)
(desktop-save-mode 1)

;; Confirm before quiting
(setq confirm-kill-emacs 'y-or-n-p)

;; Default directories
(setq default-directory (concat (getenv "HOME") "/"))

;; Scroll settings
(global-set-key "\M-n"  (lambda () (interactive) (scroll-up   4)) )
(global-set-key "\M-p"  (lambda () (interactive) (scroll-down 4)) )

;; multiple cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; column marker
(require 'fill-column-indicator)
(setq fci-rule-column 79)
(add-hook 'python-mode-hook '(lambda () (fci-mode t)))

;; Dire settings
(setq dired-dwim-target t)
(defun w32-browser (doc) (w32-shell-execute 1 doc))
(eval-after-load "dired" '(define-key dired-mode-map [f3] (lambda () (interactive) (w32-browser (dired-replace-in-string "/" "\\" (dired-get-filename))))))

;; C++ settings
(setq c-default-style "linux"
      c-basic-offset 4)

;; Auto complete
(require 'auto-complete-config)
(ac-config-default)

;; Magit rules!
(global-set-key (kbd "C-x g") 'magit-status)

;; Insert spaces for tabs
(setq-default indent-tabs-mode nil)

;; Search with regex by default
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)

;; Mouse
(mouse-avoidance-mode 'animate)

;; highlight indentation off
(add-hook 'python-mode-hook '(lambda () (setq highlight-indentation-mode -1)))

;; Flycheck
(require 'flycheck)
(global-flycheck-mode)

;; Smex
(require 'smex)
(global-set-key (kbd "M-x") 'smex)

;; Next line add new lines
(setq next-line-add-newlines t)

;; Python settings
(setq python-shell-interpreter "ipython")
(setenv "PYTHONPATH" "D:\\Projects\\Python\\")

;; elpy python development tool
(elpy-enable)
(setq python-check-command "flake8")
(setq py-autopep8-options '("--max-line-length=120"))
;; Need to install external autopep8 tool
(require 'py-autopep8)

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

(add-hook 'python-mode-hook
          (lambda ()
            (setq-default indent-tabs-mode nil)
            (setq-default tab-width 4)
            (setq-default python-indent 4)))

(defun add-py-debug ()  
      "add debug code and move line down"  
    (interactive)  
    (move-beginning-of-line 1)  
    (insert "import ipdb; ipdb.set_trace()\n"))

(global-set-key (kbd "<f9>") 'add-py-debug)

(defun remove-py-debug ()  
  "remove py debug code, if found"  
  (interactive)  
  (let ((x (line-number-at-pos))  
    (cur (point)))  
    (search-forward-regexp "^[ ]*import ipdb; ipdb.set_trace();")  
    (if (= x (line-number-at-pos))  
    (let ()  
      (move-beginning-of-line 1)  
      (kill-line 1)  
      (move-beginning-of-line 1))  
      (goto-char cur))))  

(global-set-key (kbd "M-<f9>") 'remove-py-debug)

;; Super + uppercase letter signifies a buffer/file
(global-set-key (kbd "C-c s")                       ;; scratch
                (lambda()(interactive)(switch-to-buffer "*scratch*")))
(global-set-key (kbd "C-c e")                       ;; .emacs
                (lambda()(interactive)(find-file "~/.emacs.d/init.el")))

;; Revert buffer
(global-auto-revert-mode 1)

;; Projectile settings
(setq projectile-indexing-method 'alien)
(setq projectile-enable-caching t)
(projectile-global-mode)
(setq projectile-completion-system 'ivy)
(setq projectile-enable-idle-timer t)

;; Use MingGW libraries if running on Windows
(if (eq system-type 'windows-nt)
    (setenv "PATH"
            (concat "C:\\MinGW\\msys\\1.0\\bin;" (getenv "PATH"))))

;; Toogle header/implementation file
(global-set-key (kbd "C-c o") 'ff-find-other-file)

;; js2 settings
(js2-imenu-extras-mode)

;; Web beautify :)
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c b") 'web-beautify-js))
;; Or if you're using 'js-mode' (a.k.a 'javascript-mode')
(eval-after-load 'js
  '(define-key js-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'json-mode
  '(define-key json-mode-map (kbd "C-c b") 'web-beautify-js))

(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "C-c b") 'web-beautify-html))

(eval-after-load 'css-mode
  '(define-key css-mode-map (kbd "C-c b") 'web-beautify-css))

(setq c-default-style "bsd"
  c-basic-offset 4)

;; ERC settings (IRC)
;; (require 'erc)
;; (erc-autojoin-mode t)
;; (erc-track-mode 1)
;; (setq erc-autojoin-channels-alist
;;       '((".*\\.freenode.net" "#emacs" "#python" "##networking")))
;; (setq erc-nick "aijihz") 
;; (setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
;;                                  "324" "329" "332" "333" "353" "477"))
;; (setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

;; Org mode
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; Html settings
(add-hook 'html-mode-hook
          (lambda ()
            ;; Default indentation is usually 2 spaces, changing to 4.
            (set (make-local-variable 'sgml-basic-offset) 4)))

;; Anzu mode
(global-anzu-mode +1)
(global-set-key (kbd "M-%") 'anzu-query-replace)
(global-set-key (kbd "C-M-%") 'anzu-query-replace-regexp)
;; Irony mode (for C++)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(setq w32-pipe-read-delay 0)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;; Web browsing
(global-set-key (kbd "C-x C-o") 'browse-url-at-point)
;; Kill all other buffers
(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (delq (current-buffer)
              (remove-if-not '(lambda (x)
                                (or (buffer-file-name x)
                                    (eq 'dired-mode
                                        (buffer-local-value 'major-mode x)))) (buffer-list)))))
;; neotree
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(setq neo-smart-open t)
;; ivy-mode
(add-to-list 'load-path "~/git/swiper/")
(require 'ivy)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-height 10)
(setq ivy-count-format "(%d/%d) ")
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-load-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elpy-modules
   (quote
    (elpy-module-company elpy-module-eldoc elpy-module-pyvenv elpy-module-yasnippet elpy-module-sane-defaults))))
