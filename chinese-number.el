;;; chinese-number.el --- Elisp to convert chinese number  -*- coding: utf-8 -*-

;; Copyright 2006 Ye Wenbin
;;
;; Author: wenbinye@163.com
;; Time-stamp: < 2015-11-30 11:20:07>
;; Version: 0.1.0
;; Keywords: i18n
;; X-URL: not distributed yet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This module is translated from Perl module Lingua::ZH::Numbers.

;; Put this file into your load-path and the following into your ~/.emacs:
;;   (require 'chinese-number)

;;; Code:

(provide 'chinese-number)
(eval-when-compile
  (require 'cl))

(defvar chinese-number-map
  '((pinyin
     (unit ("" . 1) ("Wan " . 10000) ("Yi " . 100000000)
           ("Shi " . 10) ("Bai " . 100) ("Qian " . 1000)
           ("Ling" . 0) ("Yi" . 1) ("Er" . 2) ("San" . 3)
           ("Si" . 4) ("Wu" . 5) ("Liu" . 6) ("Qi" . 7) ("Ba" . 8)
           ("Jiu" . 9))
     (mag "" "Wan " "Yi ")
     (ord "" "Shi " "Bai " "Qian ")
     (dig "Ling" "Yi" "Er" "San" "Si" "Wu" "Liu" "Qi" "Ba" "Jiu")
     (dot . " Dian ")
     (neg . "Fu "))
    (gb
     (unit ("" . 1) ("万" . 10000) ("亿" . 100000000)
           ("十" . 10) ("百" . 100) ("千" . 1000)
           ("零" . 0) ("一" . 1) ("二" . 2) ("三" . 3)
           ("四" . 4) ("五" . 5) ("六" . 6) ("七" . 7)
           ("八" . 8) ("九" . 9))
     (mag "" "万" "亿")
     (ord "" "十" "百" "千")
     (dig "零" "一" "二" "三" "四" "五" "六" "七" "八" "九")
     (dot . "点")
     (neg . "负"))
    (big5
     (unit ("" . 1) ("萬" . 10000) ("億" . 100000000)
           ("十" . 10) ("百" . 100) ("千" . 1000)
           ("零" . 0) ("一" . 1) ("二" . 2) ("三" . 3)
           ("四" . 4) ("五" . 5) ("六" . 6) ("七" . 7)
           ("八" . 8) ("九" . 9))
     (mag "" "萬" "億")
     (ord "" "十" "百" "千")
     (dig "零" "一" "二" "三" "四" "五" "六" "七" "八" "九")
     (dot . "點")
     (neg . "負"))
    (gb-currency
     (unit ("" . 1) ("万" . 10000) ("亿" . 100000000)
           ("拾" . 10) ("佰" . 100) ("仟" . 1000)
           ("零" . 0) ("壹" . 1) ("贰" . 2) ("参" . 3)
           ("肆" . 4) ("伍" . 5) ("陆" . 6) ("柒" . 7)
           ("捌" . 8) ("玖" . 9))
     (mag "" "万" "亿")
     (dig "零" "壹" "贰" "参" "肆" "伍" "陆" "柒" "捌" "玖")
     (ord "" "拾" "佰" "仟")
     (dot . "点")
     (neg . "负")
     (post . "圆整"))
    (big5-currency
     (unit ("" . 1) ("萬" . 10000) ("億" . 100000000)
           ("拾" . 10) ("佰" . 100) ("仟" . 1000)
           ("零" . 0) ("壹" . 1) ("貳" . 2) ("參" . 3)
           ("肆" . 4) ("伍" . 5) ("陸" . 6) ("柒" . 7)
           ("捌" . 8) ("玖" . 9))
     (mag "" "萬" "億")
     (ord  "" "拾" "佰" "仟")
     (dig "零" "壹" "貳" "參" "肆" "伍" "陸" "柒" "捌" "玖")
     (dot . "點")
     (neg . "負")
     (post . "圓整"))
    (pinyin-currency
     (unit ("" . 1) ("Wan " . 10000) ("Yi " . 100000000)
           ("Shi " . 10) ("Bai " . 100) ("Qian " . 1000)
           ("Ling" . 0) ("Yi" . 1) ("Er" . 2) ("San" . 3)
           ("Si" . 4) ("Wu" . 5) ("Liu" . 6) ("Qi" . 7) ("Ba" . 8)
           ("Jiu" . 9))
     (mag "" "Wan " "Yi ")
     (ord "" "Shi " "Bai " "Qian ")
     (dig "Ling" "Yi" "Er" "San" "Si" "Wu" "Liu" "Qi" "Ba" "Jiu")
     (dot . " Dian ")
     (neg . "Fu ")
     (post . "Yuan Zheng"))))

(defun chinese-number-number-to-zh (num map)
  (let ((str (number-to-string num))
        (mag (cdr (assoc 'mag map)))
        (dig (cdr (assoc 'dig map)))
        (neg (cdr (assoc 'neg map)))
        (ord (cdr (assoc 'ord map)))
        (dot (cdr (assoc 'dot map)))
        (out "") i n cmag len
        chunks  delta zero tmp)
    (when (string-match "\\.\\(.*\\)" str)
      (setq delta (match-string 1 str)
            str (replace-match "" nil "\\&" str )))
    (when (string-match "^-" str)
      (setq out neg
            str (replace-match "" nil "\\&" str)))
    (setq i (length str))
    (while (> i 4)
      (setq chunks (cons (substring str (- i 4) i) chunks)
            i (- i 4)))
    (setq chunks (cons (substring str 0 i) chunks))
    (setq zero (concat (regexp-quote (car dig)) "$")
          cmag (1- (length chunks)))
    (dolist (chunk chunks)
      (setq tmp nil)
      (setq len (1- (length chunk)))
      (dolist (i (number-sequence len 0 -1))
        (setq n (- (aref chunk (- len i)) ?0))
        (when (or tmp (/= n 0))
          (unless (or (and (= n 0) (string-match zero tmp))
                      (and (= i 1) (= n 1) (null tmp)))
            (setq tmp (concat tmp (nth n dig))))
          (if (/= n 0)
              (setq tmp (concat tmp (nth i ord))))))
      (unless (or (null tmp) (string= tmp (car dig)))
        (setq tmp (replace-regexp-in-string zero "" tmp)))
      (if tmp
          (setq tmp (concat tmp (nth cmag mag))))
      (if (and (< (string-to-number chunk) 1000)
               (/= cmag (1- (length chunks)))
               (not (string-match zero out)))
          (setq tmp (concat (car dig) tmp)))
      (setq out (concat out tmp))
      (setq cmag (1- cmag)))
    (unless (string= out (car dig))
      (if (string-match zero out)
          (setq out (replace-match "" nil "\\&" out))))
    (when delta
      (setq out (concat out dot
                        (mapconcat (lambda (n)
                                     (nth (- n ?0) dig))
                                   (append delta nil) ""))))
    out))

(defun chinese-number-zh-to-number (str map)
  (let ((mag (reverse (cddr (assoc 'mag map))))
        (dig (cdr (assoc 'dig map)))
        (neg (cdr (assoc 'neg map)))
        (ord (reverse (cddr (assoc 'ord map))))
        (dot (cdr (assoc 'dot map)))
        (unit (cdr (assoc 'unit map)))
        (res 0) num tmp tmpstr negflag chunks delta zero)
    (setq zero (concat "^" (regexp-quote (car dig))))
    (when (string-match (concat "^" (regexp-quote neg)) str)
      (setq negflag t
            str (replace-match "" nil "\\&" str)))
    (if (string-match (concat (regexp-quote dot) "\\(.*\\)") str)
        (setq delta (match-string 1 str)
              str (replace-match "" nil "\\&" str)))
    (dolist (m mag)
      (if (string-match (regexp-quote m) str)
          (setq chunks (cons
                        (cons (substring str 0 (match-beginning 0))
                              m) chunks)
                str (substring str (match-end 0)))))
    (if (string< "" str)
        (setq chunks (cons (cons str "") chunks)))
    (dolist (chunk chunks)
      (setq tmpstr (car chunk)
            num 0
            tmp nil)
      (dolist (m ord)
        (if (string-match (regexp-quote m) tmpstr)
            (setq tmp (cons
                       (cons (replace-regexp-in-string zero ""
                                                       (substring tmpstr 0 (match-beginning 0)))
                             m) tmp)
                  tmpstr (substring tmpstr (match-end 0)))))
      (if (string< "" tmpstr)
          (setq tmp (cons (cons (replace-regexp-in-string zero "" tmpstr) "") tmp)))
      (dolist (c tmp)
        (setq num (+ num (* (cdr (assoc (car c) unit))
                            (cdr (assoc (cdr c) unit))))))
      (setq res (+ res (* num (cdr (assoc (cdr chunk) unit))))))
    (if delta
        (setq res
              (+ res (string-to-number
                      (concat
                       "." (replace-regexp-in-string
                            (regexp-opt dig)
                            (lambda (d) (number-to-string (cdr (assoc d unit))))
                            delta))))))
    (if negflag
        (setq res (- res)))
    res))

(defun chinese-number-currency-to-zh (num map)
  (if (string-match "\\." (number-to-string num))
      (error "Sorry, Fraction currency numbers not yet supported")
    (concat
     (chinese-number-number-to-zh num map)
     (cdr (assoc 'post map)))))

(defun chinese-number-zh-to-currency (num map)
  (let ((post (concat (regexp-quote (cdr (assoc 'post map))) "$")))
    (if (string-match post num)
        (chinese-number-zh-to-number (replace-match "" nil "\\&" num) map)
      (error "Not a currency"))))

(defun chinese-number-number-to-gb (num)
  (chinese-number-number-to-zh num (cdr (assoc 'gb chinese-number-map))))

(defun chinese-number-number-to-big5 (num)
  (chinese-number-number-to-zh num (cdr (assoc 'big5 chinese-number-map))))

(defun chinese-number-number-to-pinyin (num)
  (chinese-number-number-to-zh num (cdr (assoc 'pinyin chinese-number-map))))

(defun chinese-number-currency-to-gb (num)
  (chinese-number-currency-to-zh num (cdr (assoc 'gb-currency chinese-number-map))))

(defun chinese-number-currency-to-big5 (num)
  (chinese-number-currency-to-zh num (cdr (assoc 'big5-currency chinese-number-map))))

(defun chinese-number-currency-to-pinyin (num)
  (chinese-number-currency-to-zh num (cdr (assoc 'pinyin-currency chinese-number-map))))

(defun chinese-number-gb-to-number (str)
  (chinese-number-zh-to-number str (cdr (assoc 'gb chinese-number-map))))

(defun chinese-number-big5-to-number (str)
  (chinese-number-zh-to-number str (cdr (assoc 'big5 chinese-number-map))))

(defun chinese-number-pinyin-to-number (str)
  (chinese-number-zh-to-number str (cdr (assoc 'pinyin chinese-number-map))))

(defun chinese-number-gb-to-currency (str)
  (chinese-number-zh-to-currency str (cdr (assoc 'gb-currency chinese-number-map))))

(defun chinese-number-big5-to-currency (str)
  (chinese-number-zh-to-currency str (cdr (assoc 'big5-currency chinese-number-map))))

(defun chinese-number-pinyin-to-currency (str)
  (chinese-number-zh-to-currency str (cdr (assoc 'pinyin-currency chinese-number-map))))

;;; chinese-number.el ends here
