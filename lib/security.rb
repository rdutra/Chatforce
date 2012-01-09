require 'rubygems'
require 'encryptor'

class Security
  
  def self.encrypt text
    secret_key = Digest::SHA256.hexdigest('Mt8&1Pr(')
    encrypted_value = Encryptor.encrypt(:value => text, :key => secret_key)
    return encrypted_value
  end
  
  def self.decrypt enc_value
    secret_key = Digest::SHA256.hexdigest('Mt8&1Pr(')
    decrypted_value = Encryptor.decrypt(:value => enc_value, :key => secret_key)
    return decrypted_value
  end
end
