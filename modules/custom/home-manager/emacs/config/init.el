(require 'org)

;; Define the path for the Org and Elisp files
(defvar my-org-config-file (expand-file-name "README.org" user-emacs-directory))
(defvar my-elisp-config-file (expand-file-name "config.el" user-emacs-directory))

;; Tangle the Org file to Elisp if necessary
(defun my-tangle-config-org ()
  "Tangle README.org to config.el."
  (when (file-newer-than-file-p my-org-config-file my-elisp-config-file)
    (org-babel-tangle-file my-org-config-file my-elisp-config-file)))

(my-tangle-config-org)

;; Load the Elisp file
(load-file my-elisp-config-file)

