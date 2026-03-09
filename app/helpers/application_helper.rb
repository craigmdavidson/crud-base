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

    tag.div(class: "relative inline-flex items-center justify-center w-8 h-8 rounded-full bg-blue-600 text-white text-sm font-semibold shrink-0 overflow-hidden") do
      tag.span(initials) +
      tag.img(src: gravatar_url, alt: "", class: "absolute inset-0 w-full h-full rounded-full object-cover", onerror: "this.remove()", loading: "lazy")
    end
  end
end
