(require 'chinese-number)

(defvar chinese-number-test-number
  '(123456789

    103456789
    120456789
    123056789
    123406789
    123450789
    123456089
    123456709
    123456780

    100006789
    100056789
    100456789
    103456789
    123450000
    123450009
    123450089
    123450789

    120056789
    120456789
    123056789
    
    123456009
    123456089
    123456709

    100000000
    100000009
    100000089
    100000789
    100006789
    100056789
    100456789
    103456789))

(ert-deftest chinese-number-test ()
  (with-temp-buffer
    (dolist (func '((chinese-number-gb-to-number . chinese-number-number-to-gb)
                    (chinese-number-big5-to-number . chinese-number-number-to-big5)
                    (chinese-number-pinyin-to-number . chinese-number-number-to-pinyin)
                    (chinese-number-gb-to-currency . chinese-number-currency-to-gb)
                    (chinese-number-pinyin-to-currency . chinese-number-currency-to-pinyin)
                    (chinese-number-big5-to-currency . chinese-number-currency-to-big5)))
      (dolist (num chinese-number-test-number)
        (let ((zh-str (funcall (cdr func) num)))
          (insert (format "%d => %-50s => %d\n" num zh-str (funcall (car func) zh-str)))
          (should (= num (funcall (car func) zh-str))))))))

(ert-deftest chinese-number-test-gb ()
  (should (string-equal (chinese-number-number-to-gb 10) "十")))

(ert-deftest chinese-number-test-currency ()
  (should (string-equal (chinese-number-currency-to-gb 10) "拾圆整")))
