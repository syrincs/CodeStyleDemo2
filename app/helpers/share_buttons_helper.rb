module ShareButtonsHelper
  BUTTONS = %w(facebook pinterest google-plus twitter)

  def share(item)
    BUTTONS.map do |web|
      settings = {
        type: web.gsub('-', ''),
        url: item.short_url,
        description: web == 'twitter' ? item.description[0..113] + '...' : item.description,
        media: item.decorate.thumbnail_img,
        title: item.title
      }
      link_to('', 'javascript:void(0);', data: settings, class: "prettySocial fa fa-lg fa-#{web}")
    end.join.html_safe
  end
end
