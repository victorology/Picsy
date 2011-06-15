class NicknameFormatValidator < ActiveModel::EachValidator  
  def validate_each(object, attribute, value)  
    if value.include?("@")   
      object.errors[attribute] << (options[:message] || "is invalid, forbidden to use @ character")  
    end  
  end  
end