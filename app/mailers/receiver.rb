class Receiver < ActionMailer::Base
  require 'nokogiri'
  require 'logger'
  
  default from: "opsmailer@wizards.com"
  
  def self.parse(email)
    logfile = File.open('/home/ticketeeapp.com/apps/ticketee/current/log/audit.log', 'w')    
    log = Logger.new(logfile)
    reply_separator = /(.*?)\s?From:\s+WOTC OPSmailer/m
    body = email.body.decoded
    body = Nokogiri::HTML(body).text
    comment_text = reply_separator.match(body)
    log.info "Comment = " + comment_text[1].strip if comment_text
    log.info "Email body = " + body
    comment_text.bomb
    reply_separator = /(.*?)\s?== ADD YOUR REPLY ABOVE THIS LINE ==/m
    comment_text = reply_separator.match(email.body.decoded) unless comment_text
    
    if comment_text
      to, project_id, ticket_id = email.subject.split("@")[0].split("+")
      if project_id.to_i > 0 && ticket_id.to_i > 0
        project = Project.find(project_id)
        ticket = project.tickets.find(ticket_id)
        user = User.find_by_email(email.from[0].downcase)
        comment_text = comment_text[1].strip
        comment_text = Nokogiri::HTML(comment_text).text
        comment_strip_exp = /^<!--.+-->(.+)$/m
        match_text = comment_strip_exp.match(comment_text)
        log.info "Comment = " + comment_text
        log.info "Match text = " + match_text[1] if match_text
        logfile.flush
        comment_text = match_text[1] if match_text
        ticket.comments.create(:text => comment_text, :user => user)
      end
    end
  end
end
