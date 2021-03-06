;;; Copyright (c) 2015 Ivan Shvedunov
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;;; THE SOFTWARE.

(defpackage :cl-mqtt.tests
  (:use :cl :alexandria :iterate :i4-diet-utils :vtf))

(in-package :cl-mqtt.tests)

(defparameter *message-tests*
  '((:connect
     #(#x10 ;; Fixed header, message type=0x01 (CONNECT), DUP=0, QoS=0, Retain=0
       #x1F ;; Remaining length=31
       #x00 #x04 ;; Protocol Name -- len
       #x4d #x51 #x54 #x54 ;; Protocol Name -- MQTT for MQTT 3.1.1
       #x04 ;; Protocol level -- 4 for MQTT 3.1.1
       #x02 ;; Flags:
       ;; Username Flag: 0
       ;; Password Flag: 0
       ;; Will Retain Flag: 0
       ;; Will QoS: 0 (2 bits)
       ;; Will Flag: 0
       ;; Clean Session Flag: 1
       ;; (bit 0 is reserved)
       #x00 #x3c ;; Keep Alive (secs): 60
       #x00 #x13 ;; Client ID len = 19
       #x6d #x6f #x73 #x71 #x73 #x75 #x62 #x2f ;; Client ID = mosqsub/10224-think
       #x31 #x30 #x32 #x32 #x34 #x2d #x74 #x68
       #x69 #x6e #x6b)
     (:type :connect
      :dup 0
      :qos 0
      :retain nil
      :protocol-name "MQTT"
      :protocol-level 4
      :connect-username-flag 0
      :connect-password-flag 0
      :connect-will-qos 0
      :connect-will-flag 0
      :connect-clean-session-flag 1
      :connect-keepalive 60
      :client-id "mosqsub/10224-think")
     2)
    #++
    (:connect
     #(#x10 ;; Fixed header, message type=0x01 (CONNECT), DUP=0, QoS=0, Retain=0
       #x21 ;; Remaining length=33
       #x00 #x06 ;; Protocol Name -- len
       #x4d #x51 #x49 #x73 #x64 #x70 ;; Protocol Name -- string "MQIsdp" (should be MQTT in MQTT 3.1.1)
       #x03      ;; Protocol level -- 3 (should be 4 in MQTT 3.1.1)
       #x02      ;; Flags:
       ;; Username Flag: 0
       ;; Password Flag: 0
       ;; Will Retain Flag: 0
       ;; Will QoS: 0 (2 bits)
       ;; Will Flag: 0
       ;; Clean Session Flag: 1
       ;; (bit 0 is reserved)
       #x00 #x3c ;; Keep Alive (secs): 60
       #x00 #x13 ;; Client ID len = 19
       #x6d #x6f #x73 #x71 #x73 #x75 #x62 #x2f ;; Client ID = mosqsub/10224-think
       #x31 #x30 #x32 #x32 #x34 #x2d #x74 #x68
       #x69 #x6e #x6b)
     (:type :connect
      :dup 0
      :qos 0
      :retain nil
      :protocol-name "MQIsdp"
      :protocol-level 3
      :connect-username-flag 0
      :connect-password-flag 0
      :connect-will-qos 0
      :connect-will-flag 0
      :connect-clean-session-flag 1
      :connect-keepalive 60
      :client-id "mosqsub/10224-think")
     2)

    (:connack
     #(#x20 ;; Fixed header, message type=0x02 (CONNACK), DUP=0, QoS=0, Retain=0
       #x02 ;; Remaining length=2
       #x00 ;; (unused)
       #x00 ;; Return code = 0x00 (connection accepted)
       )
     (:type :connack
      :dup 0
      :qos 0
      :retain nil
      :ret-code :accepted)
     2)

    (:publish
     #(#x31 ;; Fixed header, message type=0x03 (PUBLISH), DUP=0, QoS=0, Retain=1
       #x32 ;; Remaining length=50
       #x00 #x20 ;; Topic len=32
       ;; Topic: '/devices/zonebeast011c/meta/name'
       #x2f #x64 #x65 #x76 #x69 #x63 #x65 #x73
       #x2f #x7a #x6f #x6e #x65 #x62 #x65 #x61
       #x73 #x74 #x30 #x31 #x31 #x63 #x2f #x6d
       #x65 #x74 #x61 #x2f #x6e #x61 #x6d #x65
       ;; Payload: 'Zone Beast 01:1c'
       #x5a #x6f #x6e #x65 #x20 #x42 #x65 #x61
       #x73 #x74 #x20 #x30 #x31 #x3a #x31 #x63)
     (:type :publish
      :dup 0
      :qos 0
      :retain t
      :topic "/devices/zonebeast011c/meta/name"
      :payload #.(babel:string-to-octets "Zone Beast 01:1c" :encoding :utf-8))
     2)

    (:publish1
     #(#x33 ;; Fixed header, message type=0x03 (PUBLISH), DUP=0, QoS=1, Retain=1
       #x34 ;; Remaining length=50
       #x00 #x20 ;; Topic len=32
       ;; Topic: '/devices/zonebeast011c/meta/name'
       #x2f #x64 #x65 #x76 #x69 #x63 #x65 #x73
       #x2f #x7a #x6f #x6e #x65 #x62 #x65 #x61
       #x73 #x74 #x30 #x31 #x31 #x63 #x2f #x6d
       #x65 #x74 #x61 #x2f #x6e #x61 #x6d #x65
       #x00 #x02 ;; Message ID=2
       ;; Payload: 'Zone Beast 01:1c'
       #x5a #x6f #x6e #x65 #x20 #x42 #x65 #x61
       #x73 #x74 #x20 #x30 #x31 #x3a #x31 #x63)
     (:type :publish
      :dup 0
      :qos 1
      :retain t
      :topic "/devices/zonebeast011c/meta/name"
      :mid 2
      :payload #.(babel:string-to-octets "Zone Beast 01:1c" :encoding :utf-8))
     2)

    (:publish2
     #(#x35 ;; Fixed header, message type=0x03 (PUBLISH), DUP=0, QoS=2, Retain=1
       #x09 ;; Remaining length=9
       #x00 #x04 ;; Topic len=4
       ;; Topic: '/d/z'
       #x2f #x64 #x2f #x7a
       #x02 #x03 ;; Message ID=515
       ;; Payload: '1'
       #x31)
     (:type :publish
      :dup 0
      :qos 2
      :retain t
      :topic "/d/z"
      :mid 515
      :payload #(#x31))
     2)

    (:publish3
     #(#x30 #x88 #x01 #x00 #x06 #x2F #x61 #x2F
       #x62 #x2F #x63 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
       #x58 #x58 #x58)
     (:type :publish
      :dup 0
      :qos 0
      :retain nil
      :mid 0
      :topic "/a/b/c"
      :payload
      #(#x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58
        #x58 #x58 #x58 #x58 #x58 #x58 #x58 #x58))
     3)

    (:puback
     #(#x40      ;; Fixed header, message type=0x04 (PUBACK)
       #x02      ;; Remaining length=2
       #x02 #x04 ;; Message ID=516
       )
     (:type :puback
      :mid 516)
     2)

    (:pubrec
     #(#x50 ;; Fixed header, message type=0x05 (PUBREC)
       #x02 ;; Remaining length=2
       #x02 #x05 ;; Message ID=517
       )
     (:type :pubrec
      :mid 517)
     2)

    (:pubrel
     #(#x62 ;; Fixed header, message type=0x06 (PUBREL), QoS=1
       #x02 ;; Remaining length=2
       #x02 #x05 ;; Message ID=517
       )
     (:type :pubrel
      :mid 517
      :qos 1)
     2)

    (:pubcomp
     #(#x70 ;; Fixed header, message type=0x07 (PUBCOMP)
       #x02 ;; Remaining length=2
       #x02 #x05 ;; Message ID=517
       )
     (:type :pubcomp
      :mid 517)
     2)

    (:subscribe
     #(#x82 ;; Fixed header, message type=0x08 (SUBSCRIBE), DUP=0, QoS=1, Retain=0
       #x06 ;; Remaining length=6
       #x00 #x01 ;; Message ID=1
       #x00 #x01 ;; Topic len=1
       #x23      ;; Topic: '#'
       #x00      ;; Requested QoS = 0 (use lower 2 bits)
       )
     (:type :subscribe
      :dup 0
      :qos 1
      :retain nil
      :mid 1
      :topic "#"
      :subscription-qos 0)
     2)

    (:suback
     #(#x90 ;; Fixed header, message type=0x09 (SUBACK), DUP=0, QoS=0, Retain=0
       #x03 ;; Remaining length=3
       #x00 #x01 ;; Message ID=1
       #x00      ;; Granted QoS=0 (use lower 2 bits)
       )
     (:type :suback
      :dup 0
      :qos 0
      :retain nil
      :mid 1
      :subscription-qos 0)
     2)

    (:unsubscribe
     #(#xa2 ;; Fixed header, message type=0x0a (UNSUBSCRIBE), DUP=0, QoS=1, Retain=0
       #x05 ;; Remaining length=5
       #x00 #x01 ;; Message ID=1
       #x00 #x01 ;; Topic len=1
       #x23      ;; Topic: '#'
       )
     (:type :unsubscribe
      :dup 0
      :qos 1
      :retain nil
      :mid 1
      :topic "#"
      :subscription-qos 0)
     2)

    (:unsuback
     #(#xb0 ;; Fixed header, message type=0x0b (UNSUBACK), DUP=0, QoS=0, Retain=0
       #x02 ;; Remaining length=2
       #x00 #x01 ;; Message ID=1
       )
     (:type :unsuback
      :dup 0
      :qos 0
      :retain nil
      :mid 1)
     2)

    (:pingreq
     #(#xc0 ;; Fixed header, message type=0x0c (PINGREQ)
       #x00 ;; Remaining length=0
       )
     (:type :pingreq)
     2)

    (:pingresp
     #(#xd0 ;; Fixed header, message type=0x0d (PINGRESP)
       #x00 ;; Remaining length=0
       )
     (:type :pingresp)
     2)

    (:disconnect
     #(#xe0 ;; Fixed header, message type=0x0e (DISCONNECT)
       #x00 ;; Remaining length=0
       )
     (:type :disconnect)
     2)))

(defstruct (message-test (:type list))
  type packet message var-header-start)

(deftest test-frame-reader () ()
  (macrolet ((chk (&body body)
                           `(progn
                              (setf called-p nil)
                              ,@body
                              (is-true called-p))))
    (iter (for message-test in *message-tests*)
          (let ((packet (message-test-packet message-test))
                (called-p nil))
            (flet ((cbk (buf var-header-start)
                     (is-false called-p)
                     (is (equalp buf packet))
                     (is (= (message-test-var-header-start message-test) var-header-start))
                     (setf called-p t)))
              (let ((reader (mqtt::make-mqtt-frame-reader #'cbk)))
                (chk
                 (funcall reader packet))
                (chk
                 (iter (for i from 0 below (length packet))
                       (funcall reader (subseq packet i (1+ i)))))
                (iter (for i from 1 below (1- (length packet)))
                      (chk
                       (funcall reader (subseq packet 0 i))
                       (funcall reader (subseq packet i))))))))))

(deftest test-packet-building () ()
  ;; TBD: test all
  (dolist (message-test *message-tests*)
    (let ((message (apply #'mqtt::make-mqtt-message
                          (message-test-message message-test)))
          (buf (make-array 1024 :element-type '(unsigned-byte 8)
                                :fill-pointer 0
                                :adjustable t)))
      (mqtt::build-packet buf message)
      (is (equalp (message-test-packet message-test) buf)))))

(deftest test-packet-parsing () ()
  (dolist (message-test *message-tests*)
    (let* ((expected-message (apply #'mqtt::make-mqtt-message
                                    (message-test-message message-test)))
           (actual-message nil)
           (reader (mqtt::make-mqtt-frame-reader
                    #'(lambda (act-buf var-header-start)
                        (setf actual-message (mqtt::parse-packet act-buf var-header-start))))))
      (funcall reader (message-test-packet message-test))
      ;; this ignores case in string comparison, but this will hardly
      ;; cause any false positives
      (is (equalp expected-message actual-message)))))

;; TBD: multi-topic subscriptions (need (* :str), (* :u8) types)
;; TBD: use simpler sample publish message(s)
;; TBD: frame reader length decoder test based on values returned from the reader
;; TBD: handle DUPs
;; TBD: (note for homA stuff: subscribe w/QoS=1 for metadata topics)
;; TBD: auth
;; TBD: will
;; TBD: test parsing bad packets
;; TBD: MQTT 3.1.1

;; TBD: (note) need to send PINGREQ / PINGRESP at some interval < keep alive time
