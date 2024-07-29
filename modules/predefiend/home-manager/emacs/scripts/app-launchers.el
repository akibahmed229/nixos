;;; app-launchers.el --- Possible alternatives to dmenu/rofi


;; * APP LANUCHER
;; ** Counsel-Linux-App
;; Since we have counsel installed, we can use counsel-linux-app to launch our Linux apps.  It list the apps by their executable command, so it’s kind of tricky to use.

;;; Code:

(defun emacs-counsel-launcher ()
  ;; "Create and select a frame called emacs-counsel-launcher which consists only of a minibuffer and has specific dimensions. Runs counsel-linux-app on that frame, which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour. Delete the frame after that command has exited"
  (interactive)
  (with-selected-frame 
      (make-frame '((name . "emacs-run-launcher")
                    (minibuffer . only)
                    (fullscreen . 0) ; no fullscreen
                    (undecorated . t) ; remove title bar
                    ;;(auto-raise . t) ; focus on this frame
                    ;;(tool-bar-lines . 0)
                    ;;(menu-bar-lines . 0)
                    (internal-border-width . 10)
                    (width . 80)
                    (height . 11)))
    (unwind-protect
        (counsel-linux-app)
      (delete-frame))))



(provide 'app-launchers)
;;; app-launchers.el ends here
