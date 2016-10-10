module SimpleEncryption

  # Encrypt text using AES. For highest security, the key should be 32
  # characters long, and the initialization vector 16 characters long.
  # Shorter keys and seeds are padded. You can even leave them blank, to
  # use the default values.
  def self.aes_encrypt(plain_text, key = '', iv = '')
    require 'openssl'
    key_padding = "fZ\330\260\254Z\255\324\2074\a0\376\271\235\257E\362;\201\371\017\342\364\205\333\372\345v\317\264`"
    iv_padding = "\373\2436\bLT\230\242*\314\367\216b&\344\225"
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = (key + key_padding)[0,32]
    cipher.iv = (iv + iv_padding)[0,16]
    encrypted_text = cipher.update(plain_text)
    encrypted_text << cipher.final
  end

  # Decrypt text using AES. The key and initialization vector must match
  # what was used during encryption (duh!). For ease of use, a failed
  # decryption returns nil.
  def self.aes_decrypt(encrypted_text, key = '', iv = '')
    require 'openssl'
    key_padding = "fZ\330\260\254Z\255\324\2074\a0\376\271\235\257E\362;\201\371\017\342\364\205\333\372\345v\317\264`"
    iv_padding = "\373\2436\bLT\230\242*\314\367\216b&\344\225"
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = (key + key_padding)[0,32]
    cipher.iv = (iv + iv_padding)[0,16]
    begin
      plain_text = cipher.update(encrypted_text)
      plain_text << cipher.final
    rescue
      nil
    end
  end

  # Get a password from the passwords.yml file. This method is intended
  # to be used in database.yml. You must include SimpleEncryption, for cases
  # (namely, rake) where the full GICS environment is not loaded. Here is
  # a sample snippet from database.yml:
  #
  # <% require 'simple_encryption' %>
  # development:
  #   ...
  #   username: gsysgicst
  #   password: <%= SimpleEncryption.get_password_for_username('gsysgicst') %>
  #
  # That database.yml would need a passwords.yml that looks something like this:
  #
  # gsysgicst: aYtnOcY1wc/2KnnTIebPmA==
  #
  # One passwords.yml can hold passwords for multiple accounts. The username
  # is the key in the YAML. The file must be in the directory above the
  # application. For example, if GICS is at /opt/apps/gics/current, then
  # passwords.yml must be in /opt/apps/gics.
  #
  # To create an encrypted password, use something like the following:
  #
  # D:\apps\gics>ruby script\console
  # Loading development environment (Rails 2.1.0)
  # >> Base64.encode64(SimpleEncryption.aes_encrypt('my_pass'))
  # aYtnOcY1wc/2KnnTIebPmA==
  # => "aYtnOcY1wc/2KnnTIebPmA==\n"
  # >>
  #
  # Cut and paste the result (including the trailing ==, but not the \n or
  # quotes) into passwords.yml.
  def self.get_password_for_username(username)
    # passwords.yml lives two directories above the application
    # (i.e., app lives in /opt/apps/circportal/releases/nnnnnnnn,
    # and passwords.yml lives in /opt/apps/circportal)
    require 'base64'
    file_name = File.join(File.dirname(__FILE__), '../../../passwords.yml')
    raw_text = YAML.load_file(file_name)[username]
    SimpleEncryption.aes_decrypt(Base64.decode64(raw_text))
  end

  def self.get_password_for_user(username)
    file_name = File.join(File.dirname(__FILE__), '../../../passwords.yml')
    raw_text = YAML.load_file(file_name)[username]
    raw_text  
  end

end
