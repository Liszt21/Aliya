(defpackage aliya.system
  (:use :cl :uiop))

(in-package :aliya.system)

(defun toggle-feature (feature &optional (action t action-supplied-p))
  (let* ((p (position feature cl:*features*))
         (on (and (not p)
                  (or (not action-supplied-p)
                      (and action
                           action-supplied-p))))
         (off (and p
                   (or (not action-supplied-p)
                       (and (not action)
                            action-supplied-p)))))
    (cond
      (on
        (setf cl:*features* (cons feature cl:*features*)))
      (off
        (setf cl:*features* (remove feature cl:*features*)))
      (t cl:*features*))))

(defun command-exists (command)
  (multiple-value-bind (_ _ code)
      (uiop:run-program
       (format nil "~A ~A"
               #+os-windows "powershell -Command Get-Command"
               #-os-windows "command -v"
               command)
       :ignore-error-status t)
   (eq 0 code)))

(defun detect-features ()
  "Detect features"
  (cond
    ((command-exists "yay") (toggle-feature :yay t))
    ((command-exists "pacman") (toggle-feature :pacman  t))
    ((command-exists "apt") (toggle-feature :apt  t))
    ((command-exists "yum") (toggle-feature :yum  t))
    ((command-exists "scoop") (toggle-feature :scoop t)))
  (when (command-exists "pyenv") (toggle-feature :pyenv  t))
  (when (command-exists "nvm") (toggle-feature :nvm  t))
  (when (command-exists "julia") (toggle-feature :julia  t))
  (when (command-exists "java") (toggle-feature :java  t))
  (when (uiop:getenv "WSL_DISTRO_NAME") (toggle-feature :wsl t)))

(detect-features)

