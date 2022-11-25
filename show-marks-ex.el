;;; show-marks-ex.el -*- coding: utf-8-emacs -*-
;; Copyright (C) 2020, 2022 fubuki

;; Author: fubukiATfrill.org
;; Version: @(#)$Revision: 1.33 $$Name:  $
;; Keywords: Editing

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Extend for `show-marks.el (c) 2003 Greg Rowe - github.com/vapniks/mark'.

;;; Installation:

;; (require 'show-marks-ex)
;; (global-set-key "\C-c " 'show-marks)
;; or (global-set-key "\M-s " 'show-marks)

;;; Change Log:

;;; Code:
(require 'show-marks)

(defvar show-marks-ex-minor-mode-map
  (let ((map (make-sparse-keymap))
        (menu (make-sparse-keymap "show-mark")))
    (define-key map " "           'mark-mode-next-mark-ex)
    (define-key map "n"           'mark-mode-next-mark-ex)
    (define-key map "\M-n"        'mark-mode-next-mark-ex)
    (define-key map [down]        'mark-mode-next-mark-ex)
    (define-key map [tab]         'mark-mode-next-mark-ex)
    (define-key map [?\S- ]       'mark-mode-prev-mark-ex)
    (define-key map [backspace]   'mark-mode-prev-mark-ex)
    (define-key map "p"           'mark-mode-prev-mark-ex)
    (define-key map "\M-p"        'mark-mode-prev-mark-ex)
    (define-key map [up]          'mark-mode-prev-mark-ex)
    (define-key map [S-tab]       'mark-mode-prev-mark-ex)
    (define-key map "s"           'mark-mode-next-face)
    (define-key map "d"           'mark-mode-delete-ex)
    (define-key map "\C-d"        'mark-mode-delete-ex)
    (define-key map [C-backspace] 'mark-mode-delete-ex)
    (define-key map "j"           'mark-mode-jump)
    (define-key map "\C-m"        'mark-mode-goto-and-quit)
    (define-key map "\C-j"        'mark-mode-goto-and-quit)
    (define-key map [mouse-1]     'mark-mode-mouse-select)
    (define-key map "q"           'mark-mode-quit)
    (define-key map "Q"           'mark-mode-kill-buffer)
    (define-key map "x"           'mark-mode-kill-buffer)
    (define-key map "\C-c\C-o"    'org-toggle-link-display)
    (define-key map [menu-bar show-marks] (cons "Show Marks" menu))
    (define-key menu [org-toggle-link-display]
      '("Toggle OrgDisp" . org-toggle-link-display))
    (define-key menu [fm-toggle]
      '("Toggle Follow" . fm-toggle))
    (define-key menu [mark-mode-kill-buffer]
      '("Kill Buffer" . mark-mode-kill-buffer))
    (define-key menu [mark-mode-quit]
      '("Cancel" . mark-mode-quit))
    (define-key menu [mark-mode-delete-ex]
      '("Delete Mark" . mark-mode-delete-ex))
    (define-key menu [mark-mode-goto-and-quit]
      '("Go Mark" . mark-mode-goto-and-quit))
    (define-key menu [mark-mode-jump]
      '("Go Jump" . mark-mode-jump))
    (define-key menu [mark-mode-next-face]
      '("Skip Mark Space" . mark-mode-next-face))
    (define-key menu [mark-mode-prev-mark-ex]
      '("Previous Mark" . mark-mode-prev-mark-ex))
    (define-key menu [mark-mode-next-mark-ex]
      '("Next Mark" . mark-mode-next-mark-ex))
    map))

(define-minor-mode show-marks-ex-minor-mode
  "show-marks extend. For overriding keymaps.
\\{show-marks-ex-minor-mode-map}")
  
(defgroup show-marks nil
  "show marks group."
  :group 'editing)

(defcustom show-marks-exchange t
  "if non-nil point move to second line at startup."
  :type  'boolean
  :group 'show-marks)

(defcustom show-marks-global 7
  "show-marks global mode switch.
nil     Current buffer mode
t       Global mode
integer Global mode & Display buffer name length."
  :type '(choice (integer :tag "Global mode name width")
                 (const :tag "Current mode" :value nil)
                 (const :tag "Global mode" :value t))
  :group 'show-marks)

(defcustom show-marks-short-buffer-name-pad ?>
  "`show-marks-short-buffer-name' padding character."
  :type 'character
  :group 'show-marks)

(defcustom show-marks-add-mark-ring '(global-mark-ring)
  "mark-ring symbol."
  :type  '(repeat :tag "mark-ring sym/func" symbol)
  :group 'show-marks)

(defcustom show-marks-silence t
  "Deterrence narrow cancel message."
  :type  'boolean
  :group 'show-marks)

(defcustom show-marks-truncate-lines t
  "truncate lines."
  :type 'boolean
  :group 'show-marks)

(defcustom show-marks-display-action
  '((display-buffer-at-bottom display-buffer-below-selected)
    (window-height . fit-window-to-buffer))
  "show marks window open function."
  :type  '(choice
           (const nil)
           (repeat
            (choice
             (repeat function)
             (cons variable (choice integer function)))))
  :group 'show-marks)

(defcustom show-marks-bm-source nil
  "If non-nil, target `grobal-mark-ring' buffers.
Otherwise all buffers. for function `show-marks-bm-mark-ring'."
  :type 'boolean
  :group 'show-marks)

(defcustom mark-mode-switch-to-buffer #'switch-to-buffer
  "`mark-mode-goto-and-quit' Buffer change function."
  :type 'function
  :group 'show-marks)

(defgroup show-marks-faces nil
  "show mark faces."
  :group 'show-marks
  :group 'faces)

(defface show-marks-line-number
  '((((background light))
     :foreground "grey30")
    (t
     :foreground "grey40"))
  "Line number face."
  :group 'show-marks-faces)

(defface show-marks-match
  '((t :inherit match :extend nil))
  "Marker face."
  :group 'show-marks-faces)

(defface show-marks-match-other
  '((t :inherit isearch :extend nil))
  "Global marker face."
  :group 'show-marks-faces)

(defface show-marks-mask
  '((t :inherit default :extend nil))
  "Mask face."
  :group 'show-marks-faces)

(defface show-marks-highlight
  '((((background light))
     :underline "RoyalBlue3")
    (t
     :underline "Cyan"))
  "Highlight face."
  :group 'show-marks-faces)

(defface show-marks-mouse-highlight
    '((t :inherit highlight))
  "Highlight face."
  :group 'show-marks-faces)

(defface mark-mode-jump-key-face
  '((((background light))
     :background "grey30" :foreground "Pink" :extend nil)
    (t
     :background "grey30" :foreground "Orange" :extend nil))
  "Jump key face."
  :group 'show-marks-faces)

(defvar show-marks-point-save nil)

(defvar show-marks-ex-hook nil)

(defun mark-mode-mouse-select (event)
  (interactive "e")
  (mark-mode-goto-and-quit (posn-point (event-end event))))

(defun mark-mode-goto-and-quit (pos)
  "Quit and go."
  (interactive "d")
  (let ((mk (get-text-property pos 'marker)))
    (unless mk
      (ding)
      (beginning-of-line)
      (mark-mode-next-mark-ex)
      (setq mk (get-text-property pos 'marker)))
    (delete-window)
    (funcall mark-mode-switch-to-buffer (marker-buffer mk))
    (goto-char mk)
    (setq mark-ring (cons mk (delete mk mark-ring)))))

(defun mark-mode-goto-ex ()
  "Go to the occurrence the current line describes."
  (interactive)
  (let ((pos (get-text-property (point) 'marker)))
    (pop-to-buffer (marker-buffer pos))
    (goto-char pos)))

(defun display-fit-buffer (buff)
  "`display-buffer' with `show-marks-display-action'."
  (display-buffer buff show-marks-display-action))

(defun mark-mode-quit ()
  "Quit and return to the previous position."
  (interactive)
  (delete-window)
  (set-window-buffer (selected-window) (car show-marks-point-save))
  (set-buffer (car show-marks-point-save))
  (goto-char (cdr show-marks-point-save)))

(defun mark-mode-kill-buffer ()
  "Kill buffer & Delete window."
  (interactive)
  (let ((buff (current-buffer)))
    (if (y-or-n-p "Kill mark-mode")
        (progn
          (delete-window)
          (kill-buffer buff))
      (message nil))))

(defun mark-mode-delete-ex ()
  "Delete mark at current point from mark-ring."
  (interactive)
  (let ((mark (get-text-property (point) 'marker))
        (inhibit-read-only t)
        (beg (line-beginning-position))
        (end (line-end-position)))
    (if (null mark)
        nil
      (with-current-buffer mark-buffer
        (if (equal mark (mark-marker))
            (error "Can't delete is current mark"))
        (setq mark-ring (delete mark mark-ring))
        (setq global-mark-ring (delete mark global-mark-ring)))
      (remove-list-of-text-properties
       (point) (1+ (point)) '(marker face mouse-face help-echo))
      (when (eq end (next-single-property-change beg 'marker nil end))
        (delete-region beg (1+ end)))
      (mark-mode-next-mark-ex))))

(defun show-marks-ex (org)
  "`show-marks' extend function."
  (interactive)
  (let ((temp-buffer-show-function 'display-fit-buffer))
    (run-hooks 'show-marks-ex-hook)
    (and (get-buffer "*marks*") (kill-buffer "*marks*"))
    (setq show-marks-point-save (cons (current-buffer) (point)))
    ;; (when show-marks-exchange (push-mark))
    (push-mark)
    (funcall org)
    (set (make-local-variable 'face-remapping-alist)
         (append
          '((highlight . show-marks-highlight))
          face-remapping-alist))
    (when show-marks-exchange (forward-line))
    (mark-mode-next-mark-ex)))

(defun init-mark-mode ()
  "Functuon for `mark-mode-hook'."
  (show-marks-ex-minor-mode 1)
  (setq truncate-lines show-marks-truncate-lines))

(defvar mark-mode-current-face nil)

(defun mark-mode-next-mark-ex ()
  "Move to next mark in *mark* buffer, wrapping if necessary."
  (interactive)
  (let ((pos (point)))
    (when (get-text-property pos 'marker)
      (setq pos (1+ pos)))
    (setq pos (next-single-property-change pos 'marker))
    (unless pos
      (setq pos (next-single-property-change (point-min) 'marker)))
    ;; (setq mark-mode-current-face (get-text-property (point) 'face))
    (prog1 pos (goto-char pos))))

(defun mark-mode-prev-mark-ex ()
  "Move to previous mark in *mark* buffer, wrapping if necessary."
  (interactive)
  (let ((pos (point)))
    (when (get-text-property pos 'marker)
      (setq pos (1- pos)))
    (setq pos (previous-single-property-change pos 'marker))
    (unless pos
      (if (get-text-property (point-max) 'marker)
          (setq pos (point-max))
        (setq pos (previous-single-property-change (point-max) 'marker nil (point-min)))))
    (setq pos (1- pos))
    (prog1 pos (goto-char pos))))

(defun mark-mode-next-face ()
  "Move to next face."
  (interactive)
  (let (face)
    (setq face (get-text-property (point) 'face))
    (while (progn (mark-mode-next-mark-ex)
                  (eq face (get-text-property (point) 'face))))))

(defun mark-mode-next-ch (ch)
  (let ((next
         (and ch (assq ch '((?9 . ?a) (?p . ?r) (?z . ?A) (?Z . nil))))))
    (if next
        (cdr next)
      (and ch (1+ ch)))))

(define-minor-mode show-marks-ex-jump-mode
  "show-marks jump minor mode. \\{show-marks-ex-jump-mode-map}."
  ;; Assign to the code to skip with `mark-mode-next-ch'.
  :keymap '(("q" . mark-mode-jump-quit)))

(defun mark-mode-jump-quit ()
  (interactive)
  (show-marks-ex-jump-mode -1)
  (remove-overlays)
  (dolist (face '(show-marks-match show-marks-match-other))
    (setq face-remapping-alist
          (delete (assoc face face-remapping-alist) face-remapping-alist))))

(defun mark-mode-jump ()
  (interactive)
  (let ((ch  ?0)
        (ov (mark-mode-jump-make-disp)))
    (dolist (a ov)
      (let ((pc  (char-after (overlay-start a)))
            (dsp (propertize (string ch) 'face 'mark-mode-jump-key-face))
            (pad (propertize " " 'face 'mark-mode-jump-key-face)))
        (setq dsp
               (cond
                ((eq ?\n pc)
                 (concat dsp "\n"))
                ((eq 2 (string-width (string pc)))
                 (concat dsp pad))
                (t
                 dsp)))
        (overlay-put a 'display dsp)
        (and ch
             (define-key show-marks-ex-jump-mode-map
               (kbd (char-to-string ch))
               `(lambda ()
                  (interactive)
                  (show-marks-ex-jump-mode -1)
                  (mark-mode-goto-and-quit ,(overlay-start a)))))
        (setq ch (mark-mode-next-ch ch)))
      ;; A gimmick that apparently avoids the text property face
      ;; at the end of the line leaking to the edge of the screen for some reason.
      (setq face-remapping-alist
            (append 
             '((show-marks-match . show-marks-mask)
               (show-marks-match-other . show-marks-mask))
             face-remapping-alist))
      (message "Jump mode active.")
      (show-marks-ex-jump-mode 1))))

(defun mark-mode-jump-make-disp ()
  "Return overlay list."
  (let ((pos (point-min))
        ov)
    (while (setq pos (next-single-property-change pos 'marker))
      (if (get-text-property pos 'marker)
          (setq ov (cons (make-overlay pos (1+ pos)) ov))))
    (reverse ov)))

(defun show-marks-jp ()
  (interactive)
  (progn (show-marks) (mark-mode-jump)))

(defun show-marks-live-buffer (mark-ring)
  "Returns of live buffers from MARK-RING.
Exclude blank start buffers."
  (let (result)
    (dolist (a mark-ring (reverse result))
      (if (and (marker-buffer a)
               (string-match "\\`[^ ]" (buffer-name (marker-buffer a))))
          (setq result (cons a result))))))

(defun show-marks-safety-position-p (pos)
  "Measures narrow."
  (and (<= (point-min) pos) (>= (point-max) pos)))

(defun show-marks-short-buffer-name (buff &optional suffix)
  "Returns BUFF name with length of `show-marks-global'."
  (let* ((len (if (numberp show-marks-global) show-marks-global nil))
         (str (buffer-name buff))
         (suffix (if (or (null suffix) (zerop len)) "" suffix))
         (pad show-marks-short-buffer-name-pad))
    (if (and (numberp len) (> len (length str)))
        (setq str (concat str (make-string 32 32))))
    (concat (truncate-string-to-width str len 0 pad) suffix)))

(defun show-marks-render-buffer (marks-lst)
  "Render MARKS-LST to current buffer.
MARK-LIST is \((lineNo . buffer) . mark-line-string)"
  (let ((global show-marks-global))
    (dolist (a marks-lst)
      (let ((ln (caar a))
            (bf (cdar a)))
        (insert (propertize
                 (if global
                     (format "%6d:%s " ln (show-marks-short-buffer-name bf ":"))
                   (format "%6d: " ln))
                 'face 'show-marks-line-number))
        (insert (cdr a))))))

(defun show-marks-add-mark-ring (mark-ring)
"Added result of expression list `show-marks-add-mark-ring' to MARK-RING."
  (let ((lst mark-ring)
        (add-ring show-marks-add-mark-ring))
    (dolist (a add-ring lst)
      (setq lst (append
                 lst
                 (show-marks-live-buffer
                  (cond
                   ((functionp a)
                    (funcall a))
                   ((symbolp a)
                    (eval a))
                   (t
                    a))))))))

(defun show-marks-register-mark-ring ()
  "Return register markers `mark-ring' form."
  (let (result)
    (dolist (a register-alist result)
      (if (markerp (cdr a))
          (setq result (cons (cdr a) result))))))

(defun show-marks-flatten (lst)
  "Flattening LST."
  (cond
   ((null lst)
    nil)
   ((consp (car lst))
    (append (show-marks-flatten (car lst)) (show-marks-flatten (cdr lst))))
   (t
    (cons (car lst) (show-marks-flatten (cdr lst))))))

(when (fboundp 'bm-lists)
  (defun show-marks-bm-mark-ring ()
    "Return bm-bookmark a `mark-ring' form."
    (let ((buff-list (if show-marks-bm-source
                         (mapcar #'marker-buffer global-mark-ring)
                       (buffer-list)))
          bm result)
      (dolist (buff buff-list result)
        (if (string-match "\\` " (buffer-name buff))
            nil
          (setq result
                (append
                 (save-current-buffer
                   (set-buffer buff)
                   (when (setq bm (delq nil (show-marks-flatten (bm-lists))))
                     (dolist (a bm result)
                       (setq result
                             (cons
                              (set-marker
                               (make-marker) (overlay-start a) (overlay-buffer a))
                              result)))))
                 result)))))))

(defun show-marks-make-list (marks)
  "Expand markring MARKS to \((lineNo . buffer) . mark-line-string).
If `show-marks-global' is non-nil, add `global-mark-ring' for processing."
  (let (ln pt beg end stack tmp str highlight buff)
    (if show-marks-global
        (setq marks (show-marks-add-mark-ring marks)))
    (save-current-buffer
      (dolist (mk marks)
        (setq buff (marker-buffer mk))
        (set-buffer buff)
        (if (not (show-marks-safety-position-p (marker-position mk)))
            (and (null show-marks-silence) (message "Narrow area: %s" mk))
          (setq highlight (if (equal (current-buffer) mark-buffer)
                              'show-marks-match
                            'show-marks-match-other))
          (setq ln (line-number-at-pos mk))
          (save-excursion
            (goto-char mk)
            (setq beg (line-beginning-position)
                  end (line-end-position))
            (setq pt  (- mk beg))
            (setq tmp (assoc (cons ln buff) stack))
            (if tmp
                (setq str (cdr tmp))
              (setq str (concat (buffer-substring beg end) "\n")))
            (add-text-properties
             pt (1+ pt)
             `(face ,highlight marker ,mk mouse-face show-marks-mouse-highlight
                    help-echo ,(buffer-name buff))
             str)
            (put-text-property 0 1 'buffer buff str)
            (unless tmp (push (cons (cons ln buff) str) stack))))))
    (reverse stack)))
    
(defun show-mark-ex (marks)
  "Replaces function `show-mark'."
  (show-marks-render-buffer (show-marks-make-list marks)))

(advice-add 'show-marks :around   'show-marks-ex) ; This command.
(advice-add 'show-mark  :override 'show-mark-ex)  ; Buffer make function.
(advice-add 'mark-mode-goto :override 'mark-mode-goto-ex)

(add-hook 'mark-mode-hook #'init-mark-mode)

;; (obsolete read-only-mode "24.3") toggle-read-only 29 で完全消滅.
(when (and (<= 29 emacs-major-version)
           (not (fboundp 'toggle-read-only)))
  (defalias 'toggle-read-only #'read-only-mode))

(provide 'show-marks-ex)
;; fin.
