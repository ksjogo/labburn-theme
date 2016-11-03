;;; labburn-theme.el --- A lab color space zenburn theme.

;; Original Author: Bozhidar Batsov
;; Original URL: https://github.com/bbatsov/zenburn-emacs
;; Author: Johannes Goslar
;; Created: 5 April 2016
;; Version: 0.1.0
;; Keywords: theme, zenburn
;; URL: https://github.com/ksjogo/labburn-theme

;; Copyright (C) 2011-2016 Bozhidar Batsov
;; Copyright (C) 2015-2016 Johannes Goslar

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Credits:

;; A port by Bozhidar Batsov of the popular Vim theme Zenburn for Emacs 24, built on top
;; of the new built-in theme support in Emacs 24.
;; Further adopted by Johannes Goslar to rainbow coloring and consistent and lightness/saturation

;;;; Code:

(deftheme labburn "The labburn color theme")

;; labburn

(defconst labburn-base-lightness 80)
(defconst labburn-base-lightness-step 5)
(defconst labburn-base-saturation 25)
(defconst labburn-class '((class color) (min-colors 89)))

(custom-theme-set-variables
 'labburn
 `(rainbow-identifiers-cie-l*a*b*-lightness ,labburn-base-lightness t)
 `(rainbow-identifiers-cie-l*a*b*-saturation ,labburn-base-saturation t)
 `(rainbow-identifiers-choose-face-function 'rainbow-identifiers-cie-l*a*b*-choose-face t)
 `(rainbow-identifiers-cie-l*a*b*-color-count 1024 t))

;; we won't have the colors/rainbow-identifiers packaged loaded on startup when the theme is used
;; thus these functions were inlined here, if you know a better way, I am happy to adapt it

(defun labburn-clamp (num low high)
  (min (max num low) high))

(defconst labburn-d65-xyz '(0.950455 1.0 1.088753)
  "D65 white point in CIE XYZ.")

(defconst labburn-cie-ε (/ 216 24389.0))
(defconst labburn-cie-κ (/ 24389 27.0))

(defun labburn-lab-to-xyz (L a b &optional white-point)
  "Convert CIE L*a*b* to CIE XYZ.
WHITE-POINT specifies the (X Y Z) white point for the
conversion.  If omitted or nil, use `labburn-d65-xyz'."
  (pcase-let* ((`(,Xr ,Yr ,Zr) (or white-point labburn-d65-xyz))
               (fy (/ (+ L 16) 116.0))
               (fz (- fy (/ b 200.0)))
               (fx (+ (/ a 500.0) fy))
               (xr (if (> (expt fx 3.0) labburn-cie-ε)
                       (expt fx 3.0)
                     (/ (- (* fx 116) 16) labburn-cie-κ)))
               (yr (if (> L (* labburn-cie-κ labburn-cie-ε))
                       (expt (/ (+ L 16) 116.0) 3.0)
                     (/ L labburn-cie-κ)))
               (zr (if (> (expt fz 3) labburn-cie-ε)
                       (expt fz 3.0)
                     (/ (- (* 116 fz) 16) labburn-cie-κ))))
    (list (* xr Xr)                 ; X
          (* yr Yr)                 ; Y
          (* zr Zr))))                ; Z

(defun labburn-xyz-to-srgb (X Y Z)
  "Convert CIE X Y Z colors to sRGB color space."
  (let ((r (+ (* 3.2404542 X) (* -1.5371385 Y) (* -0.4985314 Z)))
        (g (+ (* -0.9692660 X) (* 1.8760108 Y) (* 0.0415560 Z)))
        (b (+ (* 0.0556434 X) (* -0.2040259 Y) (* 1.0572252 Z))))
    (list (if (<= r 0.0031308)
              (* 12.92 r)
            (- (* 1.055 (expt r (/ 1 2.4))) 0.055))
          (if (<= g 0.0031308)
              (* 12.92 g)
            (- (* 1.055 (expt g (/ 1 2.4))) 0.055))
          (if (<= b 0.0031308)
              (* 12.92 b)
            (- (* 1.055 (expt b (/ 1 2.4))) 0.055)))))

(defun labburn-rgb-to-hex  (red green blue)
  "Return hexadecimal notation for the color RED GREEN BLUE.
RED, GREEN, and BLUE should be numbers between 0.0 and 1.0, inclusive."
  (format "#%02x%02x%02x"
          (* red 255) (* green 255) (* blue 255)))

(defun labburn-lab-to-hex (L a b)
  (apply 'labburn-rgb-to-hex (apply 'labburn-xyz-to-srgb (labburn-lab-to-xyz L a b))))

(defun labburn-define-color (name a b &optional lightness step)
  (setq lightness (or lightness labburn-base-lightness))
  (setq step (or labburn-base-lightness-step step))
  (dotimes (i 21)
    (let* ((i (* (- i 10) 0.5))
           (suffix (replace-regexp-in-string "0$" ""
                                             (replace-regexp-in-string "\\." "" (cond
                                                                                 ((< i 0) (number-to-string i))
                                                                                 ((> i 0) (concat "+" (number-to-string i)))
                                                                                 (t "")))))
           (name (concat name suffix))
           (l (labburn-clamp (+ lightness (* i step)) 0 100)))
      (eval `(defconst ,(intern name) (labburn-lab-to-hex ,l ,a ,b))))))

(labburn-define-color "labburn-red" 21.49605264873783 8.540773333869666 67)
(labburn-define-color "labburn-orange" 13.168745714886187 23.101973510068618 75)
(labburn-define-color "labburn-yellow" -1.3751424406895363 25.127342438569976 80)
(labburn-define-color "labburn-green" -17.534332143205823 13.126938831390866 62 5)
(labburn-define-color "labburn-blue" -20.560356403992287 -8.311105653507678 80)
(labburn-define-color "labburn-magenta" 38.335076954957806 -15.842566128814228 67)
(labburn-define-color "labburn-cyan" -22.87217931855784 -8.997815401280684 84)
(labburn-define-color "labburn-bg" 0 0 27 5)
(labburn-define-color "labburn-fg" -2.7768240550932743 7.856188033624156 87)

(defvar labburn-highlight "yellow")

;;; Theme Faces
(custom-theme-set-faces
 'labburn
;;;; Built-in
;;;;; basic coloring
 `(border ((t (:background ,labburn-bg :foreground ,labburn-fg))))
 `(border-color ((t (:background ,labburn-bg))))
 `(link ((t (:foreground ,labburn-yellow :underline t))))
 `(button ((t (:foreground ,labburn-yellow :underline t))))
 `(link-visited ((t (:foreground ,labburn-yellow-2 :underline t :weight normal))))
 `(default ((t (:foreground ,labburn-fg :background ,labburn-bg))))
 `(cursor ((t (:foreground ,labburn-fg :background ,labburn-fg+1))))
 `(escape-glyph ((t (:foreground ,labburn-yellow :bold t))))
 `(fringe ((t (:foreground ,labburn-bg :background ,labburn-bg))))
 `(header-line ((t (:foreground ,labburn-yellow :background ,labburn-bg))))
 `(highlight ((t (:background ,labburn-bg+1))))
 `(success ((t (:foreground ,labburn-green))))
 `(tooltip ((t (:foreground ,labburn-fg :background ,labburn-bg+1))))
 `(warning ((t (:foreground ,labburn-orange))))
 `(error ((t (:foreground "red"))))
 `(horizontal-border ((t (:background ,labburn-bg))))
 `(variable-pitch ((t (:family "DejaVu Sans"))))
;;;;; compilation
 `(compilation-column-face ((t (:foreground ,labburn-yellow))))
 `(compilation-enter-directory-face ((t (:foreground ,labburn-green))))
 `(compilation-error-face ((t (:foreground ,labburn-red-1 :underline t))))
 `(compilation-error ((t (:foreground ,labburn-red))))
 `(compilation-face ((t (:foreground ,labburn-fg))))
 `(compilation-info-face ((t (:foreground ,labburn-blue))))
 `(compilation-info ((t (:foreground ,labburn-green+4 :underline t))))
 `(compilation-leave-directory-face ((t (:foreground ,labburn-green))))
 `(compilation-line-face ((t (:foreground ,labburn-yellow))))
 `(compilation-line-number ((t (:foreground ,labburn-yellow))))
 `(compilation-message-face ((t (:foreground ,labburn-blue))))
 `(compilation-warning-face ((t (:foreground ,labburn-orange :underline t))))
 `(compilation-mode-line-exit ((t (:foreground ,labburn-green+2))))
 `(compilation-mode-line-fail ((t (:foreground ,labburn-red))))
 `(compilation-mode-line-run ((t (:foreground ,labburn-yellow))))
;;;;; completions
 `(custom-state ((t (:foreground ,labburn-green))))
 `(custom-link ((t (:foreground ,labburn-yellow :underline t))))
 `(custom-face-tag ((t (:foreground ,labburn-blue))))
;;;;; completions
 `(completions-annotations ((t (:foreground ,labburn-fg-1))))
;;;;; grep
 `(grep-context-face ((t (:foreground ,labburn-fg))))
 `(grep-error-face ((t (:foreground ,labburn-red-1 :underline t))))
 `(grep-hit-face ((t (:foreground ,labburn-blue))))
 `(grep-match-face ((t (:foreground ,labburn-orange))))
 `(match ((t (:background ,labburn-bg-1 :foreground ,labburn-orange))))
;;;;; info
 `(Info-quoted ((t (:inherit font-lock-constant-face))))
;;;;; isearch
 `(isearch ((t (:foreground ,labburn-highlight))))
 `(isearch-fail ((t (:foreground ,labburn-fg :background ,labburn-red-4))))
 `(lazy-highlight ((t (:foreground ,labburn-yellow-2 :background ,labburn-bg-05))))

 `(menu ((t (:foreground ,labburn-fg :background ,labburn-bg))))
 `(minibuffer-prompt ((t (:foreground ,labburn-yellow))))
 `(mode-line
   ((,labburn-class (:foreground ,labburn-green+1 :background ,labburn-bg-1 :box (:line-width -1 :style released-button)))
    (t :inverse-video t)))
 `(mode-line-buffer-id ((t (:foreground ,labburn-yellow))))
 `(mode-line-inactive
   ((t (:foreground ,labburn-green-1 :background ,labburn-bg-05 :box (:line-width -1 :style released-button)))))
 `(region ((,labburn-class (:background ,labburn-bg-1))
           (t :inverse-video t)))
 `(secondary-selection ((t (:background ,labburn-bg+2))))
 `(trailing-whitespace ((t (:background ,labburn-red))))
 `(vertical-border ((t (:background ,labburn-bg :foreground ,labburn-bg))))
;;;;; font lock
 `(font-lock-builtin-face ((t (:foreground ,labburn-fg+1))))
 `(font-lock-comment-face ((t (:foreground ,labburn-green))))
 `(font-lock-comment-delimiter-face ((t (:foreground ,labburn-green-1))))
 `(font-lock-constant-face ((t (:foreground ,labburn-green+4))))
 `(font-lock-doc-face ((t (:foreground ,labburn-green+2))))
 `(font-lock-function-name-face ((t (:foreground ,labburn-cyan))))
 `(font-lock-keyword-face ((t (:foreground ,labburn-yellow))))
 `(font-lock-negation-char-face ((t (:foreground ,labburn-yellow))))
 `(font-lock-preprocessor-face ((t (:foreground ,labburn-blue+1))))
 `(font-lock-regexp-grouping-construct ((t (:foreground ,labburn-yellow+2))))
 `(font-lock-regexp-grouping-backslash ((t (:foreground ,labburn-green+2))))
 `(font-lock-string-face ((t (:foreground ,labburn-red))))
 `(font-lock-type-face ((t (:foreground ,labburn-blue-1))))
 `(font-lock-variable-name-face ((t (:foreground ,labburn-orange))))
 `(font-lock-warning-face ((t (:foreground ,labburn-yellow-2))))
 `(c-annotation-face ((t (:inherit font-lock-constant-face))))
;;;; Third-party
;;;;; ace-jump
 `(ace-jump-face-background
   ((t (:inverse-video nil))))
 `(ace-jump-face-foreground
   ((t (:foreground ,labburn-highlight))))
;;;;; ace-window
 `(aw-background-face
   ((t (:foreground ,labburn-fg-1 :background ,labburn-bg :inverse-video nil))))
 `(aw-leading-char-face ((t (:inherit aw-mode-line-face))))
;;;;; avy
 `(avy-background-face
   ((t (:foreground ,labburn-fg-3 :background ,labburn-bg :inverse-video nil))))
 `(avy-lead-face-0
   ((t (:foreground ,labburn-highlight :background ,labburn-bg :inverse-video nil))))
 `(avy-lead-face-1
   ((t (:foreground ,labburn-highlight :background ,labburn-bg :inverse-video nil))))
 `(avy-lead-face-2
   ((t (:foreground ,labburn-highlight :background ,labburn-bg :inverse-video nil))))
 `(avy-lead-face
   ((t (:foreground ,labburn-highlight :background ,labburn-bg :inverse-video nil))))
;;;;; anzu
 `(anzu-mode-line ((t (:foreground ,labburn-cyan))))
 `(anzu-match-1 ((t (:foreground ,labburn-bg :background ,labburn-green))))
 `(anzu-match-2 ((t (:foreground ,labburn-bg :background ,labburn-orange))))
 `(anzu-match-3 ((t (:foreground ,labburn-bg :background ,labburn-blue))))
 `(anzu-replace-to ((t (:foreground ,labburn-highlight :background ,labburn-bg-4))))
 `(anzu-replace-highlight ((t (:foreground ,labburn-highlight))))
;;;;; auctex
 `(font-latex-bold-face ((t (:inherit bold))))
 `(font-latex-warning-face ((t (:foreground nil :inherit font-lock-warning-face))))
 `(font-latex-sectioning-5-face ((t (:foreground ,labburn-red ))))
 `(font-latex-sedate-face ((t (:foreground ,labburn-yellow))))
 `(font-latex-italic-face ((t (:foreground ,labburn-fg :slant italic))))
 `(font-latex-string-face ((t (:inherit ,font-lock-string-face))))
 `(font-latex-math-face ((t (:foreground ,labburn-orange))))
 `(TeX-fold-folded-face ((t (:foreground ,labburn-orange))))
 `(TeX-fold-unfolded-face ((t (:background ,labburn-bg+2))))
;;;;; magic-latex
 ;; `(italic ((t (:inherit font-latex-italic-face))))
 `(ml/subsection ((t (:foreground ,labburn-red :height 1.2))))
 `(ml/section ((t (:foreground ,labburn-red :height 1.6))))
 `(ml/chapter ((t (:foreground ,labburn-red :height 1.8))))
 `(ml/title ((t (:foreground ,labburn-red :height 2.0))))
 `(jg/tex-header ((t (:foreground ,labburn-red))))
;;;;; bm
 `(bm-face ((t (:background ,labburn-yellow-1 :foreground ,labburn-bg))))
 `(bm-fringe-face ((t (:background ,labburn-yellow-1 :foreground ,labburn-bg))))
 `(bm-fringe-persistent-face ((t (:background ,labburn-green-1 :foreground ,labburn-bg))))
 `(bm-persistent-face ((t (:background ,labburn-green-1 :foreground ,labburn-bg))))
;;;;; cider
 `(cider-result-overlay-face ((t (:background unspecified))))
 `(cider-enlightened-face ((t (:box (:color ,labburn-orange :line-width -1)))))
 `(cider-enlightened-local-face ((t (:weight bold :foreground ,labburn-green+1))))
 `(cider-deprecated-face ((t (:background ,labburn-yellow-2))))
 `(cider-instrumented-face ((t (:box (:color ,labburn-red :line-width -1)))))
 `(cider-traced-face ((t (:box (:color ,labburn-cyan :line-width -1)))))
 `(cider-test-failure-face ((t (:background ,labburn-red-4))))
 `(cider-test-error-face ((t (:background ,labburn-magenta))))
 `(cider-test-success-face ((t (:background ,labburn-green-1))))
;;;;; company-mode
 `(company-tooltip ((t (:foreground ,labburn-fg :background ,labburn-bg+1 :weight normal))))
 `(company-tooltip-selection ((t (:background ,labburn-bg+2 :weight normal))))
 `(company-tooltip-mouse ((t (:background ,labburn-bg-1 :weight normal))))
 `(company-tooltip-common ((t (:foreground ,labburn-orange :background ,labburn-bg+1 :weight normal))))
 `(company-tooltip-annotation-selection ((t (:foreground ,labburn-orange :background ,labburn-bg-1))))
 `(company-tooltip-annotation ((t (:foreground "#999999" :background ,labburn-bg+1 :weight normal))))
 `(company-tooltip-common-selection ((t (:foreground ,labburn-orange :background ,labburn-bg+1 :weight normal))))
 `(company-scrollbar-fg ((t (:background ,labburn-orange))))
 `(company-scrollbar-bg ((t (:background ,labburn-bg+2))))
 `(company-preview ((t (:background ,labburn-bg-1))))
 `(company-preview-common ((t (:foreground ,labburn-fg))))
 `(company-preview-search ((t (:foreground ,labburn-yellow))))
 `(company-template-field ((t (:background ,labburn-bg-1))))
;;;;; context-coloring
 `(context-coloring-level-0-face ((t :foreground ,labburn-fg)))
 `(context-coloring-level-1-face ((t :foreground ,labburn-cyan)))
 `(context-coloring-level-2-face ((t :foreground ,labburn-green+4)))
 `(context-coloring-level-3-face ((t :foreground ,labburn-yellow)))
 `(context-coloring-level-4-face ((t :foreground ,labburn-orange)))
 `(context-coloring-level-5-face ((t :foreground ,labburn-magenta)))
 `(context-coloring-level-6-face ((t :foreground ,labburn-blue+1)))
 `(context-coloring-level-7-face ((t :foreground ,labburn-green+2)))
 `(context-coloring-level-8-face ((t :foreground ,labburn-yellow-2)))
 `(context-coloring-level-9-face ((t :foreground ,labburn-red+1)))
;;;;; coq
 `(coq-solve-tactics-face ((t (:foreground nil :inherit font-lock-constant-face))))
;;;;; ctable
 `(ctbl:face-cell-select ((t (:background ,labburn-blue :foreground ,labburn-bg))))
 `(ctbl:face-continue-bar ((t (:background ,labburn-bg-05 :foreground ,labburn-bg))))
 `(ctbl:face-row-select ((t (:background ,labburn-cyan :foreground ,labburn-bg))))
;;;;; diff
 `(diff-added          ((t (:background "#335533" :foreground ,labburn-green))))
 `(diff-changed        ((t (:background "#555511" :foreground ,labburn-yellow-1))))
 `(diff-removed        ((t (:background "#553333" :foreground ,labburn-red-2))))
 `(diff-refine-added   ((t (:background "#338833" :foreground ,labburn-green+4))))
 `(diff-refine-change  ((t (:background "#888811" :foreground ,labburn-yellow))))
 `(diff-refine-removed ((t (:background "#883333" :foreground ,labburn-red))))
 `(diff-header ((,labburn-class (:background ,labburn-bg+2))
                (t (:background ,labburn-fg :foreground ,labburn-bg))))
 `(diff-file-header
   ((,labburn-class (:background ,labburn-bg+2 :foreground ,labburn-fg :bold t))
    (t (:background ,labburn-fg :foreground ,labburn-bg :bold t))))
;;;;; diff-hl
 `(diff-hl-change ((,labburn-class (:foreground ,labburn-blue :background ,labburn-blue-2))))
 `(diff-hl-delete ((,labburn-class (:foreground ,labburn-red+1 :background ,labburn-red-1))))
 `(diff-hl-insert ((,labburn-class (:foreground ,labburn-green+1 :background ,labburn-green-1))))
;;;;; dired
 `(dired-directory ((t (:foreground ,labburn-orange))))
 `(dired-marked ((t (:foreground ,labburn-highlight))))
 `(dired-mark ((t (:foreground ,labburn-highlight))))
 `(dired-perm-write ((t (:foreground ,labburn-red+2))))
;;;;; dired+
 `(diredp-display-msg ((t (:foreground ,labburn-blue))))
 `(diredp-compressed-file-suffix ((t (:foreground ,labburn-orange))))
 `(diredp-date-time ((t (:foreground ,labburn-fg-2))))
 `(diredp-deletion ((t (:foreground ,labburn-yellow))))
 `(diredp-deletion-file-name ((t (:foreground ,labburn-red))))
 `(diredp-dir-heading ((t (:foreground ,labburn-orange))))
 `(diredp-dir-name ((t (:foreground ,labburn-orange))))
 `(diredp-dir-priv ((t (:foreground ,labburn-orange-2))))
 `(diredp-exec-priv ((t (:foreground ,labburn-red-2))))
 `(diredp-executable-tag ((t (:foreground ,labburn-green+1))))
 `(diredp-file-name ((t (:foreground ,labburn-fg))))
 `(diredp-file-suffix ((t (:foreground ,labburn-fg))))
 `(diredp-flag-mark ((t (:foreground ,labburn-yellow))))
 `(diredp-flag-mark-line ((t (:foreground ,labburn-orange))))
 `(diredp-ignored-file-name ((t (:foreground ,labburn-fg-4))))
 `(diredp-link-priv ((t (:foreground ,labburn-yellow-2))))
 `(diredp-mode-line-flagged ((t (:foreground ,labburn-yellow))))
 `(diredp-mode-line-marked ((t (:foreground ,labburn-orange))))
 `(diredp-no-priv ((t (:foreground ,labburn-fg-2))))
 `(diredp-number ((t (:foreground ,labburn-green-2))))
 `(diredp-other-priv ((t (:foreground ,labburn-yellow-2))))
 `(diredp-rare-priv ((t (:foreground ,labburn-red-2))))
 `(diredp-read-priv ((t (:foreground ,labburn-green-2))))
 `(diredp-symlink ((t (:foreground ,labburn-yellow))))
 `(diredp-write-priv ((t (:foreground ,labburn-magenta-2))))
 ;; `(dired-directory ((t (:foreground "#7f9f7f"))))
 ;; `(dired-perm-write ((t (:inherit default))))
;;;;; dired-async
 `(dired-async-failures ((t (:foreground ,labburn-red))))
 `(dired-async-message ((t (:foreground ,labburn-yellow))))
 `(dired-async-mode-message ((t (:foreground ,labburn-yellow))))
;;;;; edebug
 `(hi-edebug-x-debug-line ((t (:foreground ,labburn-highlight))))
 `(hi-edebug-x-stop ((t (:background ,labburn-blue-5))))
;;;;; ediff
 `(ediff-current-diff-A ((t (:foreground ,labburn-fg :background ,labburn-red-4))))
 `(ediff-current-diff-Ancestor ((t (:foreground ,labburn-fg :background ,labburn-red-4))))
 `(ediff-current-diff-B ((t (:foreground ,labburn-fg :background ,labburn-green-1))))
 `(ediff-current-diff-C ((t (:foreground ,labburn-fg :background ,labburn-blue-5))))
 `(ediff-even-diff-A ((t (:background ,labburn-bg+1))))
 `(ediff-even-diff-Ancestor ((t (:background ,labburn-bg+1))))
 `(ediff-even-diff-B ((t (:background ,labburn-bg+1))))
 `(ediff-even-diff-C ((t (:background ,labburn-bg+1))))
 `(ediff-fine-diff-A ((t (:foreground ,labburn-fg :background ,labburn-red-2))))
 `(ediff-fine-diff-Ancestor ((t (:foreground ,labburn-fg :background ,labburn-red-2 weight bold))))
 `(ediff-fine-diff-B ((t (:foreground ,labburn-fg :background ,labburn-green))))
 `(ediff-fine-diff-C ((t (:foreground ,labburn-fg :background ,labburn-blue-3 ))))
 `(ediff-odd-diff-A ((t (:background ,labburn-bg+2))))
 `(ediff-odd-diff-Ancestor ((t (:background ,labburn-bg+2))))
 `(ediff-odd-diff-B ((t (:background ,labburn-bg+2))))
 `(ediff-odd-diff-C ((t (:background ,labburn-bg+2))))
;;;;; elfeed
 `(elfeed-log-error-level-face ((t (:foreground ,labburn-red))))
 `(elfeed-log-info-level-face ((t (:foreground ,labburn-blue))))
 `(elfeed-log-warn-level-face ((t (:foreground ,labburn-yellow))))
 `(elfeed-search-date-face ((t (:foreground ,labburn-yellow-1 :underline t))))
 `(elfeed-search-tag-face ((t (:foreground ,labburn-green))))
 `(elfeed-search-feed-face ((t (:foreground ,labburn-cyan))))
 `(elfeed-search-unread-title-face ((t (:foreground ,labburn-fg+2))))
 `(elfeed-search-title-face ((t (:foreground ,labburn-fg-1))))
;;;;; erc
 `(erc-action-face ((t (:inherit erc-default-face))))
 `(erc-bold-face ((t (:weight bold))))
 `(erc-current-nick-face ((t (:foreground ,labburn-blue))))
 `(erc-dangerous-host-face ((t (:inherit font-lock-warning-face))))
 `(erc-default-face ((t (:foreground ,labburn-fg))))
 `(erc-direct-msg-face ((t (:inherit erc-default-face))))
 `(erc-error-face ((t (:inherit font-lock-warning-face))))
 `(erc-fool-face ((t (:inherit erc-default-face))))
 `(erc-highlight-face ((t (:inherit hover-highlight))))
 `(erc-input-face ((t (:foreground ,labburn-yellow))))
 `(erc-keyword-face ((t (:foreground ,labburn-blue))))
 `(erc-nick-default-face ((t (:foreground ,labburn-yellow))))
 `(erc-my-nick-face ((t (:foreground ,labburn-red))))
 `(erc-nick-msg-face ((t (:inherit erc-default-face))))
 `(erc-notice-face ((t (:foreground ,labburn-green))))
 `(erc-pal-face ((t (:foreground ,labburn-orange))))
 `(erc-prompt-face ((t (:foreground ,labburn-orange :background ,labburn-bg))))
 `(erc-timestamp-face ((t (:foreground ,labburn-green+4))))
 `(erc-underline-face ((t (:underline t))))
;;;;; eshell
 `(eshell-prompt ((t (:foreground ,labburn-yellow))))
 `(eshell-ls-archive ((t (:foreground ,labburn-red-1))))
 `(eshell-ls-backup ((t (:inherit font-lock-comment-face))))
 `(eshell-ls-clutter ((t (:inherit font-lock-comment-face))))
 `(eshell-ls-directory ((t (:foreground ,labburn-blue+1))))
 `(eshell-ls-executable ((t (:foreground ,labburn-red+1))))
 `(eshell-ls-unreadable ((t (:foreground ,labburn-fg))))
 `(eshell-ls-missing ((t (:inherit font-lock-warning-face))))
 `(eshell-ls-product ((t (:inherit font-lock-doc-face))))
 `(eshell-ls-special ((t (:foreground ,labburn-yellow))))
 `(eshell-ls-symlink ((t (:foreground ,labburn-cyan))))
;;;;; eval-sexp-fu-flash
 `(eval-sexp-fu-flash ((t (:foreground ,labburn-highlight))))
 `(eval-sexp-fu-flash-error ((t (:foreground "red"))))
;;;;; flx
 `(flx-highlight-face ((t (:foreground ,labburn-green+2))))
;;;;; flycheck
 `(flycheck-error
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-red-1) :inherit unspecified))
    (t (:foreground ,labburn-red-1 :underline t))))
 `(flycheck-warning
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-yellow) :inherit unspecified))
    (t (:foreground ,labburn-yellow :underline t))))
 `(flycheck-info
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-cyan) :inherit unspecified))
    (t (:foreground ,labburn-cyan :underline t))))
 `(flycheck-fringe-error ((t (:foreground ,labburn-red-1))))
 `(flycheck-fringe-warning ((t (:foreground ,labburn-yellow))))
 `(flycheck-fringe-info ((t (:foreground ,labburn-cyan))))
;;;;; flyspell
 `(flyspell-duplicate
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-orange) :inherit unspecified))
    (t (:foreground ,labburn-orange :underline t))))
 `(flyspell-incorrect
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-red) :inherit unspecified))
    (t (:foreground ,labburn-red-1 :underline t))))
;;;;geben
 `(geben-backtrace-fileuri ((t (:foreground ,labburn-green+1))))
;;;;; git-commit
 `(git-commit-comment-action ((,labburn-class (:foreground ,labburn-green+1))))
 `(git-commit-comment-branch ((,labburn-class (:foreground ,labburn-blue+1))))
 `(git-commit-comment-heading ((,labburn-class (:foreground ,labburn-yellow))))
;;;;; git-rebase
 `(git-rebase-hash ((t (:foreground ,labburn-orange))))
;;;; guide-key
 `(guide-key/highlight-command-face ((t (:foreground ,labburn-blue))))
 `(guide-key/key-face ((t (:foreground ,labburn-green))))
 `(guide-key/prefix-command-face ((t (:foreground ,labburn-green+1))))
;;;;; helm
 `(helm-header
   ((t (:foreground ,labburn-green :background ,labburn-bg :underline nil :box nil))))
 `(helm-source-header
   ((t (:foreground ,labburn-yellow :background ,labburn-bg-1 :underline nil :box (:line-width -1 :style released-button)))))
 `(helm-selection ((t (:background ,labburn-bg+1 :underline nil))))
 `(helm-selection-line ((t (:background ,labburn-bg+1))))
 `(helm-visible-mark ((t (:foreground ,labburn-bg :background ,labburn-yellow-2))))
 `(helm-candidate-number ((t (:foreground ,labburn-green+4 :background ,labburn-bg-1))))
 `(helm-separator ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(helm-time-zone-current ((t (:foreground ,labburn-green+2 :background ,labburn-bg))))
 `(helm-time-zone-home ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(helm-bookmark-addressbook ((t (:foreground ,labburn-orange :background ,labburn-bg))))
 `(helm-bookmark-directory ((t (:foreground nil :background nil :inherit helm-ff-directory))))
 `(helm-bookmark-file ((t (:foreground nil :background nil :inherit helm-ff-file))))
 `(helm-bookmark-gnus ((t (:foreground ,labburn-magenta :background ,labburn-bg))))
 `(helm-bookmark-info ((t (:foreground ,labburn-green+2 :background ,labburn-bg))))
 `(helm-bookmark-man ((t (:foreground ,labburn-yellow :background ,labburn-bg))))
 `(helm-bookmark-w3m ((t (:foreground ,labburn-magenta :background ,labburn-bg))))
 `(helm-buffer-not-saved ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(helm-buffer-process ((t (:foreground ,labburn-cyan :background ,labburn-bg))))
 `(helm-buffer-saved-out ((t (:foreground ,labburn-fg :background ,labburn-bg))))
 `(helm-buffer-size ((t (:foreground ,labburn-fg-1 :background ,labburn-bg))))
 `(helm-ff-directory ((t (:foreground ,labburn-orange :background ,labburn-bg))))
 `(helm-ff-file ((t (:foreground ,labburn-fg :background ,labburn-bg :weight normal))))
 `(helm-ff-executable ((t (:foreground ,labburn-green+2 :background ,labburn-bg :weight normal))))
 `(helm-ff-invalid-symlink ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(helm-ff-symlink ((t (:foreground ,labburn-yellow :background ,labburn-bg))))
 `(helm-ff-prefix ((t (:foreground ,labburn-bg :background ,labburn-yellow :weight normal))))
 `(helm-grep-cmd-line ((t (:foreground ,labburn-cyan :background ,labburn-bg))))
 `(helm-grep-file ((t (:foreground ,labburn-fg :background ,labburn-bg))))
 `(helm-grep-finish ((t (:foreground ,labburn-green+2 :background ,labburn-bg))))
 `(helm-grep-lineno ((t (:foreground ,labburn-fg-1 :background ,labburn-bg))))
 `(helm-grep-match ((t (:foreground nil :background nil :inherit helm-match))))
 `(helm-grep-running ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(helm-match ((t (:foreground ,labburn-yellow :background ,labburn-bg))))
 `(helm-moccur-buffer ((t (:foreground ,labburn-cyan :background ,labburn-bg))))
 `(helm-mu-contacts-address-face ((t (:foreground ,labburn-fg-1 :background ,labburn-bg))))
 `(helm-mu-contacts-name-face ((t (:foreground ,labburn-fg :background ,labburn-bg))))
 `(helm-source-header ((t (:foreground ,labburn-yellow :background ,labburn-bg-2 :underline nil))))
 `(helm-swoop-target-line-block-face ((t (:background ,labburn-bg+1))))
 `(helm-swoop-target-line-face ((t (:background ,labburn-bg+1))))
 `(helm-swoop-target-word-face ((t (:foreground ,labburn-highlight))))
;;;;; hydra
 `(hydra-face-red ((t (:foreground ,labburn-red-1 :background ,labburn-bg))))
 `(hydra-face-amaranth ((t (:foreground ,labburn-red-3 :background ,labburn-bg))))
 `(hydra-face-blue ((t (:foreground ,labburn-blue :background ,labburn-bg))))
 `(hydra-face-pink ((t (:foreground ,labburn-magenta :background ,labburn-bg))))
 `(hydra-face-teal ((t (:foreground ,labburn-cyan :background ,labburn-bg))))
;;;;; iedit-mode
 `(iedit-occurrence ((t (:background ,labburn-bg+2))))
;;;;; ivy
 `(ivy-confirm-face ((t (:foreground ,labburn-green :background ,labburn-bg))))
 `(ivy-match-required-face ((t (:foreground ,labburn-red :background ,labburn-bg))))
 `(ivy-remote ((t (:foreground ,labburn-blue :background ,labburn-bg))))
 `(ivy-subdir ((t (:foreground ,labburn-yellow :background ,labburn-bg))))
 `(ivy-current-match ((t (:background ,labburn-bg+1))))
 `(ivy-minibuffer-match-face-1 ((t (:background ,labburn-bg+1))))
 `(ivy-minibuffer-match-face-2 ((t (:background ,labburn-bg+1))))
 `(ivy-minibuffer-match-face-3 ((t (:background ,labburn-bg+1))))
 `(ivy-minibuffer-match-face-4 ((t (:background ,labburn-bg+1))))
;;;;; js2-mode
 `(js2-warning ((t (:underline (:style wave :color ,labburn-orange)))))
 `(js2-error ((t (:underline (:style wave :color ,labburn-red)))))
 `(js2-jsdoc-tag ((t (:inherit font-lock-doc-face))))
 `(js2-jsdoc-type ((t (:inherit font-lock-doc-face))))
 `(js2-jsdoc-value ((t (:inherit font-lock-doc-face))))
 `(js2-function-param ((t (:foreground ,labburn-orange))))
 `(js2-external-variable ((t (:underline (:style wave :color ,labburn-orange)))))
 `(js2-jsdoc-html-tag-delimiter ((t (:inherit web-mode-html-tag-face))))
 `(js2-jsdoc-html-tag-name ((t (:inherit web-mode-html-tag-face))))
;;;;; additional js2 mode attributes for better syntax highlighting
 `(js2-instance-member ((t (:foreground ,labburn-green-1))))
 `(js2-jsdoc-html-tag-delimiter ((t (:foreground ,labburn-orange))))
 `(js2-jsdoc-html-tag-name ((t (:foreground ,labburn-red-1))))
 `(js2-object-property ((t (:foreground ,labburn-blue+1))))
 `(js2-magic-paren ((t (:foreground ,labburn-blue-5))))
 `(js2-private-function-call ((t (:foreground ,labburn-cyan))))
 `(js2-function-call ((t (:foreground ,labburn-cyan))))
 `(js2-private-member ((t (:foreground ,labburn-blue-1))))
 `(js2-keywords ((t (:foreground ,labburn-magenta))))
;;;;; linum-mode
 `(linum ((t (:foreground ,labburn-bg+3 :background ,labburn-bg :height 0.6))))
 `(linum-relative-current-face ((t (:inherit linum))))
;;;;; lispy
 `(lispy-command-name-face ((t (:background ,labburn-bg-05 :inherit font-lock-function-name-face))))
 `(lispy-cursor-face ((t (:foreground ,labburn-bg :background ,labburn-fg))))
 `(lispy-face-hint ((t (:inherit highlight :foreground ,labburn-yellow))))
;;;;; ruler-mode
 `(ruler-mode-column-number ((t (:inherit 'ruler-mode-default :foreground ,labburn-fg))))
 `(ruler-mode-fill-column ((t (:inherit 'ruler-mode-default :foreground ,labburn-yellow))))
 `(ruler-mode-goal-column ((t (:inherit 'ruler-mode-fill-column))))
 `(ruler-mode-comment-column ((t (:inherit 'ruler-mode-fill-column))))
 `(ruler-mode-tab-stop ((t (:inherit 'ruler-mode-fill-column))))
 `(ruler-mode-current-column ((t (:foreground ,labburn-yellow :box t))))
 `(ruler-mode-default ((t (:foreground ,labburn-green+2 :background ,labburn-bg))))
;;;;; magit
;;;;;; headings and diffs
 `(magit-section-highlight           ((t (:background ,labburn-bg+05))))
 `(magit-section-heading             ((t (:foreground ,labburn-yellow))))
 `(magit-section-heading-selection   ((t (:foreground ,labburn-orange))))
 `(magit-diff-file-heading           ((t (:weight bold))))
 `(magit-diff-file-heading-highlight ((t (:background ,labburn-bg+05 ))))
 `(magit-diff-file-heading-selection ((t (:background ,labburn-bg+05
                                                      :foreground ,labburn-orange))))
 `(magit-diff-hunk-heading           ((t (:background ,labburn-bg+1))))
 `(magit-diff-hunk-heading-highlight ((t (:background ,labburn-bg+2))))
 `(magit-diff-hunk-heading-selection ((t (:background ,labburn-bg+2
                                                      :foreground ,labburn-orange))))
 `(magit-diff-lines-heading          ((t (:background ,labburn-orange
                                                      :foreground ,labburn-bg+2))))
 `(magit-diff-context-highlight      ((t (:background ,labburn-bg+05
                                                      :foreground "grey70"))))
 `(magit-diffstat-added   ((t (:foreground ,labburn-green+4))))
 `(magit-diffstat-removed ((t (:foreground ,labburn-red))))
;;;;;; popup
 `(magit-popup-heading             ((t (:foreground ,labburn-yellow ))))
 `(magit-popup-key                 ((t (:foreground ,labburn-green-1))))
 `(magit-popup-argument            ((t (:foreground ,labburn-green  ))))
 `(magit-popup-disabled-argument   ((t (:foreground ,labburn-fg-1    :weight normal))))
 `(magit-popup-option-value        ((t (:foreground ,labburn-blue-2 ))))
;;;;;; process
 `(magit-process-ok    ((t (:foreground ,labburn-green ))))
 `(magit-process-ng    ((t (:foreground ,labburn-red   ))))
;;;;;; log
 `(magit-log-author    ((t (:foreground ,labburn-orange))))
 `(magit-log-date      ((t (:foreground ,labburn-fg-1))))
 `(magit-log-graph     ((t (:foreground ,labburn-fg+1))))
;;;;;; sequence
 `(magit-sequence-pick ((t (:foreground ,labburn-yellow-2))))
 `(magit-sequence-stop ((t (:foreground ,labburn-green))))
 `(magit-sequence-part ((t (:foreground ,labburn-yellow))))
 `(magit-sequence-head ((t (:foreground ,labburn-blue))))
 `(magit-sequence-drop ((t (:foreground ,labburn-red))))
 `(magit-sequence-done ((t (:foreground ,labburn-fg-1))))
 `(magit-sequence-onto ((t (:foreground ,labburn-fg-1))))
;;;;;; bisect
 `(magit-bisect-good ((t (:foreground ,labburn-green))))
 `(magit-bisect-skip ((t (:foreground ,labburn-yellow))))
 `(magit-bisect-bad  ((t (:foreground ,labburn-red))))
;;;;;; blame
 `(magit-blame-heading ((t (:background ,labburn-bg-1 :foreground ,labburn-blue-2))))
 `(magit-blame-hash    ((t (:background ,labburn-bg-1 :foreground ,labburn-blue-2))))
 `(magit-blame-name    ((t (:background ,labburn-bg-1 :foreground ,labburn-orange))))
 `(magit-blame-date    ((t (:background ,labburn-bg-1 :foreground ,labburn-orange))))
 `(magit-blame-summary ((t (:background ,labburn-bg-1 :foreground ,labburn-blue-2
                                        ))))
;;;;;; references etc
 `(magit-dimmed         ((t (:foreground ,labburn-bg+3))))
 `(magit-hash           ((t (:foreground ,labburn-bg+3))))
 `(magit-tag            ((t (:foreground ,labburn-orange))))
 `(magit-branch-remote  ((t (:foreground ,labburn-green ))))
 `(magit-branch-local   ((t (:foreground ,labburn-blue  ))))
 `(magit-branch-current ((t (:foreground ,labburn-blue   :box t))))
 `(magit-head           ((t (:foreground ,labburn-blue  ))))
 `(magit-refname        ((t (:background ,labburn-bg+2 :foreground ,labburn-fg))))
 `(magit-refname-stash  ((t (:background ,labburn-bg+2 :foreground ,labburn-fg))))
 `(magit-refname-wip    ((t (:background ,labburn-bg+2 :foreground ,labburn-fg))))
 `(magit-signature-good      ((t (:foreground ,labburn-green))))
 `(magit-signature-bad       ((t (:foreground ,labburn-red))))
 `(magit-signature-untrusted ((t (:foreground ,labburn-yellow))))
 `(magit-cherry-unmatched    ((t (:foreground ,labburn-cyan))))
 `(magit-cherry-equivalent   ((t (:foreground ,labburn-magenta))))
 `(magit-reflog-commit       ((t (:foreground ,labburn-green))))
 `(magit-reflog-amend        ((t (:foreground ,labburn-magenta))))
 `(magit-reflog-merge        ((t (:foreground ,labburn-green))))
 `(magit-reflog-checkout     ((t (:foreground ,labburn-blue))))
 `(magit-reflog-reset        ((t (:foreground ,labburn-red))))
 `(magit-reflog-rebase       ((t (:foreground ,labburn-magenta))))
 `(magit-reflog-cherry-pick  ((t (:foreground ,labburn-green))))
 `(magit-reflog-remote       ((t (:foreground ,labburn-cyan))))
 `(magit-reflog-other        ((t (:foreground ,labburn-cyan))))
;;;;; message-mode
 `(message-cited-text ((t (:inherit font-lock-comment-face))))
 `(message-header-name ((t (:foreground ,labburn-green+1))))
 `(message-header-other ((t (:foreground ,labburn-green))))
 `(message-header-to ((t (:foreground ,labburn-yellow))))
 `(message-header-cc ((t (:foreground ,labburn-yellow))))
 `(message-header-newsgroups ((t (:foreground ,labburn-yellow))))
 `(message-header-subject ((t (:foreground ,labburn-orange))))
 `(message-header-xheader ((t (:foreground ,labburn-green))))
 `(message-mml ((t (:foreground ,labburn-yellow))))
 `(message-separator ((t (:inherit font-lock-comment-face))))
;;;;; mini-header-line
 `(mini-header-line-active ((t (:background ,labburn-bg-2))))
;;;;; mu4e
 `(mu4e-header-key-face ((t (:inherit custom-link :underline nil))))
 ;;;;; neotree
 `(neo-banner-face ((t (:foreground ,labburn-blue+1 :weight bold))))
 `(neo-header-face ((t (:foreground ,labburn-fg))))
 `(neo-root-dir-face ((t (:foreground ,labburn-blue+1 :weight bold))))
 `(neo-dir-link-face ((t (:foreground ,labburn-blue))))
 `(neo-file-link-face ((t (:foreground ,labburn-fg))))
 `(neo-expand-btn-face ((t (:foreground ,labburn-blue))))
 `(neo-vc-default-face ((t (:foreground ,labburn-fg+1))))
 `(neo-vc-user-face ((t (:foreground ,labburn-red :slant italic))))
 `(neo-vc-up-to-date-face ((t (:foreground ,labburn-fg))))
 `(neo-vc-edited-face ((t (:foreground ,labburn-magenta))))
 `(neo-vc-needs-merge-face ((t (:foreground ,labburn-red+1))))
 `(neo-vc-unlocked-changes-face ((t (:foreground ,labburn-red :background ,labburn-blue-5))))
 `(neo-vc-added-face ((t (:foreground ,labburn-green+1))))
 `(neo-vc-conflict-face ((t (:foreground ,labburn-red+1))))
 `(neo-vc-missing-face ((t (:foreground ,labburn-red+1))))
 `(neo-vc-ignored-face ((t (:foreground ,labburn-fg-1))))
;;;;; org-mode
 `(org-agenda-date-today
   ((t (:foreground ,labburn-fg+1 :slant italic))) t)
 `(org-agenda-structure
   ((t (:inherit font-lock-comment-face))))
 `(org-archived ((t (:foreground ,labburn-fg))))
 `(org-checkbox ((t (:background ,labburn-bg+2 :foreground ,labburn-fg+1 :box (:line-width 1 :style released-button)))))
 `(org-date ((t (:foreground ,labburn-blue :underline t))))
 `(org-deadline-announce ((t (:foreground ,labburn-red-1))))
 `(org-done ((t (:bold t :foreground ,labburn-green+3))))
 `(org-formula ((t (:foreground ,labburn-yellow-2))))
 `(org-headline-done ((t (:foreground ,labburn-green+3))))
 `(org-hide ((t (:foreground ,labburn-bg-1))))
 `(org-level-1 ((t (:foreground ,labburn-orange))))
 `(org-level-2 ((t (:foreground ,labburn-green+4))))
 `(org-level-3 ((t (:foreground ,labburn-blue-1))))
 `(org-level-4 ((t (:foreground ,labburn-yellow-2))))
 `(org-level-5 ((t (:foreground ,labburn-cyan))))
 `(org-level-6 ((t (:foreground ,labburn-green+2))))
 `(org-level-7 ((t (:foreground ,labburn-red-4))))
 `(org-level-8 ((t (:foreground ,labburn-blue-4))))
 `(org-link ((t (:foreground ,labburn-yellow-2 :underline t))))
 `(org-scheduled ((t (:foreground ,labburn-green+4))))
 `(org-scheduled-previously ((t (:foreground ,labburn-red))))
 `(org-scheduled-today ((t (:foreground ,labburn-blue+1))))
 `(org-sexp-date ((t (:foreground ,labburn-blue+1 :underline t))))
 `(org-special-keyword ((t (:inherit font-lock-comment-face))))
 `(org-table ((t (:foreground ,labburn-green+2))))
 `(org-tag ((t (:bold t))))
 `(org-time-grid ((t (:foreground ,labburn-orange))))
 `(org-todo ((t (:bold t :foreground ,labburn-red))))
 `(org-upcoming-deadline ((t (:inherit font-lock-keyword-face))))
 `(org-warning ((t (:bold t :foreground ,labburn-red :underline nil))))
 `(org-column ((t (:background ,labburn-bg-1))))
 `(org-column-title ((t (:background ,labburn-bg-1 :underline t))))
 `(org-mode-line-clock ((t (:foreground ,labburn-fg :background ,labburn-bg-1))))
 `(org-mode-line-clock-overrun ((t (:foreground ,labburn-bg :background ,labburn-red-1))))
 `(org-ellipsis ((t (:foreground ,labburn-yellow-1 :underline t))))
 `(org-footnote ((t (:foreground ,labburn-cyan :underline t))))
 `(org-document-title ((t (:foreground ,labburn-blue))))
 `(org-document-info ((t (:foreground ,labburn-blue))))
 `(org-habit-ready-face ((t :background ,labburn-green)))
 `(org-habit-alert-face ((t :background ,labburn-yellow-1 :foreground ,labburn-bg)))
 `(org-habit-clear-face ((t :background ,labburn-blue-3)))
 `(org-habit-overdue-face ((t :background ,labburn-red-3)))
 `(org-habit-clear-future-face ((t :background ,labburn-blue-4)))
 `(org-habit-ready-future-face ((t :background ,labburn-green-1)))
 `(org-habit-alert-future-face ((t :background ,labburn-yellow-2 :foreground ,labburn-bg)))
 `(org-habit-overdue-future-face ((t :background ,labburn-red-4)))
;;;;; outline
 `(outline-1 ((t (:foreground ,labburn-orange))))
 `(outline-2 ((t (:foreground ,labburn-green+4))))
 `(outline-3 ((t (:foreground ,labburn-blue-1))))
 `(outline-4 ((t (:foreground ,labburn-yellow-2))))
 `(outline-5 ((t (:foreground ,labburn-cyan))))
 `(outline-6 ((t (:foreground ,labburn-green+2))))
 `(outline-7 ((t (:foreground ,labburn-red-4))))
 `(outline-8 ((t (:foreground ,labburn-blue-4))))
;;;;; pdf-tools
 `(pdf-view-midnight-colors '(,labburn-fg . ,labburn-bg-05))
;;;;; rainbow-delimiters
 `(rainbow-delimiters-depth-1-face ((t (:foreground ,labburn-fg))))
 `(rainbow-delimiters-depth-2-face ((t (:foreground ,labburn-green+4))))
 `(rainbow-delimiters-depth-3-face ((t (:foreground ,labburn-yellow-2))))
 `(rainbow-delimiters-depth-4-face ((t (:foreground ,labburn-cyan))))
 `(rainbow-delimiters-depth-5-face ((t (:foreground ,labburn-green+2))))
 `(rainbow-delimiters-depth-6-face ((t (:foreground ,labburn-blue+1))))
 `(rainbow-delimiters-depth-7-face ((t (:foreground ,labburn-yellow-1))))
 `(rainbow-delimiters-depth-8-face ((t (:foreground ,labburn-green+1))))
 `(rainbow-delimiters-depth-9-face ((t (:foreground ,labburn-blue-2))))
 `(rainbow-delimiters-depth-10-face ((t (:foreground ,labburn-orange))))
 `(rainbow-delimiters-depth-11-face ((t (:foreground ,labburn-green))))
 `(rainbow-delimiters-depth-12-face ((t (:foreground ,labburn-blue-5))))
 `(rainbow-delimiters-unmatched-face ((t (:foreground "red"))))
;;;;; rtags
 `(rtags-errline ((t (:underline (:color "red" :style wave)))))
 `(rtags-fixitline ((t (:underline (:color "#93E0E3" :style wave)))))
 `(rtags-warnline ((t (:underline (:color "orange" :style wave)))))
;;;;; ruby
 `(enh-ruby-op-face ((t (:inherit default))))
 `(enh-ruby-string-delimiter-face ((t (:inherit font-lock-string-face))))
 `(erm-syn-errline ((t (:underline (:color "red" :style wave)))))
 `(erm-syn-warnline ((t (:underline (:color "orange" :style wave)))))
;;;;; sh-mode
 `(sh-heredoc     ((t (:foreground ,labburn-yellow :bold t))))
 `(sh-quoted-exec ((t (:foreground ,labburn-red))))
;;;;; show-paren
 `(show-paren-mismatch ((t (:foreground ,labburn-red))))
 `(show-paren-match ((t (:foreground ,labburn-highlight))))
;;;;; smartparens
 `(sp-show-pair-enclosing-face ((t (:foreground ,labburn-highlight))))
 `(sp-show-pair-match-face ((t (:foreground ,labburn-highlight))))
 `(sp-show-pair-mismatch-face ((t (:foreground ,labburn-red))))
;;;;; sml-mode-line
 '(sml-modeline-end-face ((t :inherit default :width condensed)))
;;;;; SLIME
 `(slime-repl-output-face ((t (:foreground ,labburn-red))))
 `(slime-repl-inputed-output-face ((t (:foreground ,labburn-green))))
 `(slime-error-face
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-red)))
    (t
     (:underline ,labburn-red))))
 `(slime-warning-face
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-orange)))
    (t
     (:underline ,labburn-orange))))
 `(slime-style-warning-face
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-yellow)))
    (t
     (:underline ,labburn-yellow))))
 `(slime-note-face
   ((((supports :underline (:style wave)))
     (:underline (:style wave :color ,labburn-green)))
    (t
     (:underline ,labburn-green))))
 `(slime-highlight-face ((t (:inherit highlight))))
;;;;; term
 `(swiper-line-face ((t (nil))))
;;;;; term
 `(term-color-black ((t (:foreground ,labburn-bg :background ,labburn-bg-1))))
 `(term-color-red ((t (:foreground ,labburn-red-2 :background ,labburn-red-4))))
 `(term-color-green ((t (:foreground ,labburn-green :background ,labburn-green+2))))
 `(term-color-yellow ((t (:foreground ,labburn-orange :background ,labburn-yellow))))
 `(term-color-blue ((t (:foreground ,labburn-blue-1 :background ,labburn-blue-4))))
 `(term-color-magenta ((t (:foreground ,labburn-magenta :background ,labburn-red))))
 `(term-color-cyan ((t (:foreground ,labburn-cyan :background ,labburn-blue))))
 `(term-color-white ((t (:foreground ,labburn-fg :background ,labburn-fg-1))))
 '(term-default-fg-color ((t (:inherit term-color-white))))
 '(term-default-bg-color ((t (:inherit term-color-black))))
;;;;; ts
 `(ts-block-face ((t (:inherit font-lock-keyword-face))) t)
 `(ts-html-face ((t (:foreground ,labburn-red))))
;;;;; undo-tree
 `(undo-tree-visualizer-active-branch-face ((t (:foreground ,labburn-fg+1))))
 `(undo-tree-visualizer-current-face ((t (:foreground ,labburn-red-1))))
 `(undo-tree-visualizer-default-face ((t (:foreground ,labburn-fg))))
 `(undo-tree-visualizer-register-face ((t (:foreground ,labburn-yellow))))
 `(undo-tree-visualizer-unmodified-face ((t (:foreground ,labburn-cyan))))
;;;;; volatile-highlights
 `(vhl/default-face ((t (:inherit highlight))))
;;;;; web-mode
 `(web-mode-builtin-face ((t (:inherit ,font-lock-builtin-face))))
 `(web-mode-comment-face ((t (:inherit ,font-lock-comment-face))))
 `(web-mode-constant-face ((t (:inherit ,font-lock-constant-face))))
 `(web-mode-css-at-rule-face ((t (:foreground ,labburn-orange ))))
 `(web-mode-css-prop-face ((t (:foreground ,labburn-orange))))
 `(web-mode-css-pseudo-class-face ((t (:foreground ,labburn-green+3))))
 `(web-mode-css-rule-face ((t (:foreground ,labburn-blue))))
 `(web-mode-doctype-face ((t (:inherit ,font-lock-comment-face))))
 `(web-mode-folded-face ((t (:underline t))))
 `(web-mode-function-name-face ((t (:foreground ,labburn-blue))))
 `(web-mode-html-attr-name-face ((t (:foreground ,labburn-orange))))
 `(web-mode-html-attr-value-face ((t (:inherit ,font-lock-string-face))))
 `(web-mode-html-tag-face ((t (:foreground ,labburn-cyan))))
 `(web-mode-keyword-face ((t (:inherit ,font-lock-keyword-face))))
 `(web-mode-preprocessor-face ((t (:inherit ,font-lock-preprocessor-face))))
 `(web-mode-string-face ((t (:inherit ,font-lock-string-face))))
 `(web-mode-type-face ((t (:inherit ,font-lock-type-face))))
 `(web-mode-variable-name-face ((t (:inherit ,font-lock-variable-name-face))))
 `(web-mode-server-background-face ((t (:background ,labburn-bg))))
 `(web-mode-server-comment-face ((t (:inherit web-mode-comment-face))))
 `(web-mode-server-string-face ((t (:inherit web-moaivyde-string-face))))
 `(web-mode-symbol-face ((t (:inherit font-lock-constant-face))))
 `(web-mode-warning-face ((t (:inherit font-lock-warning-face))))
 `(web-mode-whitespaces-face ((t (:background ,labburn-red))))
 `(web-mode-function-call-face ((t (:inherit default))))
;;;;; widgets
 ;; `(widget-button ((t (:foreground ,labburn-yellow+1))))
;;;;; whitespace-mode
 `(whitespace-space ((t (:background ,labburn-bg+1 :foreground ,labburn-bg+1))))
 `(whitespace-hspace ((t (:background ,labburn-bg+1 :foreground ,labburn-bg+1))))
 `(whitespace-tab ((t (:background ,labburn-red-1))))
 `(whitespace-newline ((t (:foreground ,labburn-bg+1))))
 `(whitespace-trailing ((t (:background ,labburn-red))))
 `(whitespace-line ((t (:background ,labburn-bg :foreground ,labburn-magenta))))
 `(whitespace-space-before-tab ((t (:background ,labburn-orange :foreground ,labburn-orange))))
 `(whitespace-indentation ((t (:background ,labburn-yellow :foreground ,labburn-red))))
 `(whitespace-empty ((t (:background ,labburn-yellow))))
 `(whitespace-space-after-tab ((t (:background ,labburn-yellow :foreground ,labburn-red))))
;;;;; which-func-mode
 `(which-func ((t (:foreground ,labburn-green+4))))
;;;;; xcscope
 `(cscope-file-face ((t (:foreground ,labburn-yellow))))
 `(cscope-function-face ((t (:foreground ,labburn-cyan))))
 `(cscope-line-number-face ((t (:foreground ,labburn-red))))
 `(cscope-mouse-face ((t (:foreground ,labburn-bg :background ,labburn-blue+1))))
 `(cscope-separator-face ((t (:foreground ,labburn-red
                                          :underline t :overline t))))
 )

;;;###autoload
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path
                  (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'labburn)
;;; labburn-theme.el ends here
