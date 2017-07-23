module ApplicationHelper
  def current_category?(category, children: true)
    @category && (category.id == @category.id || (children && category.id == @category.parent.try(:id)))
  end

  def last_week_winner
    'Michael Ashwin'
  end

  # @param [Symbol] :desktop, :tablet or :mobile
  def for_device_type(*wanted_device_types)
    unless block_given?
      raise ArgumentError, 'Device helper takes a block of content to render for given device.'
    end

    unless device_type
      raise 'Mobvious device type not set. Did you add the Mobvious rack middleware?'
    end

    if wanted_device_types.include? device_type
      yield
    else
      nil
    end
  end

  # @return [Symbol] device type for current request
  def device_type
    request.env['mobvious.device_type']
  end

  def lc_visitor
    if current_user.present?
      {
        email: current_user.email,
        name: current_user.full_name
      }
    else
      {}
    end.to_json.html_safe
  end

  def lc_params
    if current_user.present?
      [{name: 'Login', value: current_user.email},
       {name: 'Account ID', value: current_user.id},
       {name: 'Total order value', value: current_user.total_order_value},
       {name: 'Orders', value: current_user.orders.count}]
    else
      []
    end.to_json.html_safe
  end

  def has_url?(options)
    url_for(controller: controller_path, action: :search)
  rescue ActionController::UrlGenerationError
    false
  end

  def humanize secs, *args
    options = args.extract_options!
    options[:last]
    amounts = {s: 60, m: 60, h: 24, d: 365}
    elements = [:s, :m, :h, :d].inject([]){ |s, name|
      if secs > 0
        count = amounts[name.to_sym]
        secs, n = secs.divmod(count)
        s.unshift "#{n.to_i}#{name}" if name.present?
      end
      s
    }

    if options[:last].present?
      elements = elements.first(options[:last])
    end

    elements.join(' ')
  end

  def body_class
    classes = []
    classes <<
      if request.path == root_path
        :front
      elsif request.path =~ /^\/dashboard/
        :dashboard
      else
        :inner
      end

    if current_user
      classes << :authorized
    else
      classes << :guest
    end

    classes.map(&:to_s).join(' ')
  end

  # def billing_address user
  #   ba = user.billing_address
  #   display = Sanitize.fragment("#{ba.first_name} #{ba.last_name}".strip, Sanitize::Config::USERINPUT)
  #
  #   display.concat "<br>"
  #
  #   display.concat Sanitize.fragment("#{ba.address1}#{ba.address2.present? ? " #{ba.address2}" : ''}, #{ba.city}, #{ba.state}, #{ba.zip_code}", Sanitize::Config::USERINPUT)
  #   display.html_safe
  # end

  def sanitize_input str
    Sanitize.fragment(str, Sanitize::Config::USERINPUT)
  end

  def scope_class(scope, active_when_empty=false)
    current_scope = respond_to?(:scope) ? self.scope : params[:scope]
    'active' if current_scope == scope || (active_when_empty && current_scope.blank?)
  end

  def paginate_page_status(collection)
    content_tag :small, "Page #{params[:page].presence || 1} of #{collection.total_pages}", class: 'info pull-right'
  end

  def message_product_path(message)
    if message.product.seller == current_user
      dashboard_store_product_path(message.product)
    else
      product_path(message.product)
    end
  end
end
