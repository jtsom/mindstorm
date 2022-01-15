module ApplicationHelper
  
  def errors_for(object, message=nil)
    html = ""
    unless object.errors.blank?
      html << "<div class='formErrors #{object.class.name.humanize.downcase}Errors'>\n"
      if message.blank?
        if object.new_record?
          html << "\t\t<h2>There was a problem creating the #{object.class.name.humanize.downcase}</h2>\n"
        else
          html << "\t\t<h2>There was a problem updating the #{object.class.name.humanize.downcase}</h2>\n"
        end    
      else
        html << "<h2>#{message}</h2>"
      end  
      html << "\t\t<ul>\n"
      object.errors.full_messages.each do |error|
        html << "\t\t\t<li class=""errorMessage"">#{error}</li>\n"
      end
      html << "\t\t</ul>\n"
      html << "\t</div>\n"
    end
    html.html_safe
  end
  
end
