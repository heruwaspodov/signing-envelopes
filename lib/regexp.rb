# frozen_string_literal: true

module REGEXP
  EMAIL = URI::MailTo::EMAIL_REGEXP
  public_constant :EMAIL

  NAME = /\A[a-zA-Z\s,.'\-()]+\z/
  public_constant :NAME

  USERNAME = /\A[a-zA-Z0-9\s,.'\-()]+\z/
  public_constant :USERNAME

  NUMBER = /\A\d+\z/
  public_constant :NUMBER

  COMPANY_NAME = /(?=.*[a-zA-Z\d\s])^[^*@#$%^[^\x00-\x7F]]*\z/
  public_constant :COMPANY_NAME

  PWD = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}\z/
  public_constant :PWD

  NIK = /^(1[0-9]|21|[37][1-6]|5[1-3]|6[1-5]|[89][12]|9[2-6])
\d{2}\d{2}([04][1-9]|[1256][0-9]|[37][01])(0[1-9]|1[0-2])\d{2}\d{4}$/x
  public_constant :NIK
  # https://www.huzefril.com/posts/regex/regex-ktp/

  REPLACER = /(?<=\{)(.*?)(?=\})/m
  public_constant :REPLACER

  PASSCODE = %r{^(?!.*[<>&#\s])[a-zA-Z0-9!@#$%^&*()_+{}\[\]:;"',./\\|\-=?]{6,50}$}
  public_constant :PASSCODE

  HEX_COLOR = /\A#(?:[0-9a-fA-F]{3}){1,2}(?:[0-9a-fA-F]{2})?\z/
  public_constant :HEX_COLOR

  UUID = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
  public_constant :UUID

  ISO8601_DATETIME = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z\z/
  public_constant :ISO8601_DATETIME
end
