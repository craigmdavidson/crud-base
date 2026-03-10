module ApplicationHelper
  def avatar_for(user, size: 32)
    email = user.email_address
    hash = Digest::MD5.hexdigest(email)
    gravatar_url = "https://www.gravatar.com/avatar/#{hash}?s=#{size * 2}&d=404"
    initials = if user.name.present?
      user.name.split.map(&:first).join.upcase[0, 2]
    else
      email[0].upcase
    end

    tag.div(class: "avatar avatar-placeholder") do
      tag.div(class: "bg-neutral text-neutral-content w-8 h-8 rounded-full relative overflow-hidden") do
        tag.span(initials, class: "text-xs") +
        tag.img(src: gravatar_url, alt: "", class: "absolute inset-0 w-full h-full rounded-full object-cover", onerror: "this.remove()", loading: "lazy")
      end
    end
  end
end
