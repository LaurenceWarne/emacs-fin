;;; finito-view.el --- Buffer utilities for finito -*- lexical-binding: t -*-

;; Copyright (C) 2021 Laurence Warne

;; Author: Laurence Warne

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

;;; Commentary:
;;
;; This file contains utilities for working with libro finito buffers

;;; Code:

(require 'cl-lib)
(require 's)

(require 'finito-core)

(defface finito-author-name
  '((t :foreground "aquamarine"
       :weight bold
       :underline t))
  "Face for author names."
  :group 'finito)

(defface finito-book-descriptions
  '((t :italic t))
  "Face for book descriptions."
  :group 'finito)

(defclass finito-book-writer ()
  nil
  "A class for writing book information to a buffer.")

(cl-defmethod finito-insert-book ((writer finito-book-writer) book-alist)
  "Write BOOK-ALIST into the current buffer using WRITER."
  (let* ((title (alist-get 'title book-alist))
         (authors (alist-get 'authors book-alist))
         (description (alist-get 'description book-alist))
         (image-file-name (alist-get 'image-file-name book-alist)))
    (finito-insert-title writer title)
    (finito-insert-image writer image-file-name)
    (finito-insert-author writer authors)
    (finito-insert-description writer description)))

(cl-defmethod finito-insert-title ((writer finito-book-writer) title)
  "Insert TITLE into the current buffer using WRITER."
  (insert (concat "** " title "\n\n")))

(cl-defmethod finito-insert-image ((writer finito-book-writer) image)
  "Insert IMAGE (an image file name) into the current buffer using WRITER."
  (insert (concat "[[" image "]]  ")))

(cl-defmethod finito-insert-author ((writer finito-book-writer) authors)
  "Insert AUTHORS into the current buffer using WRITER."
  (let ((authors-str (s-join ", " authors)))
    (insert (concat authors-str "\n\n"))
    (overlay-put (make-overlay (- (point) 2) (- (point) (length authors-str) 2))
                 'face
                 'finito-author-name)))

(cl-defmethod finito-insert-description ((writer finito-book-writer) description)
  "Insert DESCRIPTION into the current buffer using WRITER."
  (insert (concat description "\n\n"))
    (overlay-put (make-overlay (- (point) 2) (- (point) (length description) 2))
                 'face
                 'finito-book-descriptions))

(defclass finito-buffer-info ()
  ((title :initarg :title
          :type string
          :custom string
          :documentation "The title of the finito buffer.")
   (mode :initarg :mode
         :type function
         :custom function
         :documentation "The mode the finito buffer should use."))
  "A class for holding information about a finito buffer.")

(cl-defmethod finito-init-buffer ((buffer-info finito-buffer-info))
  "Initialise the current buffer according to the properties of BUFFER-INFO."
  (funcall (oref buffer-info mode)))

(defclass finito-collection-buffer-info (finito-buffer-info)
  nil
  "A class for holding information about a finito collection buffer.")

(cl-defmethod finito-init-buffer ((buffer-info finito-collection-buffer-info))
  "Initialise the current buffer according to the properties of BUFFER-INFO."
  (cl-call-next-method)
  (setq finito--collection (oref buffer-info title)))

(provide 'finito-buffer)
;;; finito-buffer.el ends here
