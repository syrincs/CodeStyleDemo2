module SeoTitlesHelper
  def seo_home_page_title
    'Online Marketplace - best bidding site: buy and sell any product at 1bid1.com'
  end

  def seo_home_page_h1
    'Online Marketplace'
  end

  def seo_title_for_category(category)
    if respond_to?(:"seo_#{category.code.underscore}_title")
      public_send(:"seo_#{category.code.underscore}_title")
    else
      "Auctions #{category.name.singularize.downcase} for sale by owner online - buy cheap #{category.name.pluralize.downcase} from auction in USA"
    end
  end

  def seo_h1_for_category(category)
    if respond_to?(:"seo_#{category.code.underscore}_h1")
      public_send(:"seo_#{category.code.underscore}_h1")
    else
      "Auction online #{@category.name.downcase} for sale by owner"
    end
  end

  def seo_condition
    if params[:condition].present? && params[:condition].size == 1
      params[:condition].first
    end
  end

  ############## CARS ###############

  def seo_auto_moto_h1
    case seo_condition
    when 'used'
      seo_used_auto_moto_h1
    when 'new'
      seo_new_auto_moto_h1
    when 'antique'
      seo_antique_auto_moto_h1
    else
      'Auction car for sale by owner'
    end
  end

  def seo_auto_moto_title
    case seo_condition
    when 'used'
      seo_used_auto_moto_title
    when 'new'
      seo_new_auto_moto_title
    when 'antique'
      seo_antique_auto_moto_title
    else
      'Auction car for sale by owner online - buy cheap cars in USA'
    end
  end

  def seo_used_auto_moto_title
    'Used cars for sale by owner - buy cheap car at auction in USA'
  end

  def seo_used_auto_moto_h1
    'Used cars for sale'
  end

  def seo_new_auto_moto_title
    'Buy cheapest new car at auction in USA'
  end

  def seo_new_auto_moto_h1
    'New cars for sale'
  end

  def seo_antique_auto_moto_title
    'Antique and vintage cars for sale - buy classic car at auction in USA'
  end

  def seo_antique_auto_moto_h1
    'Antique and vintage cars for sale'
  end

  ############## AUTO PARTS ###############

  def seo_autoparts_title
    case seo_condition
    when 'used'
      seo_used_autoparts_title
    when 'new'
      seo_new_autoparts_title
    when 'antique'
      seo_antique_autoparts_title
    else
      'Auto parts auction online - buy and sale cheap cars parts at auction in USA'
    end
  end

  def seo_autoparts_h1
    case seo_condition
    when 'used'
      seo_used_autoparts_h1
    when 'new'
      seo_new_autoparts_h1
    when 'antique'
      seo_antique_autoparts_h1
    else
      'Auction auto parts'
    end
  end

  def seo_used_autoparts_title
    'Used auto parts for sale online - buy cheap car parts at auction in USA'
  end

  def seo_used_autoparts_h1
    'Used auto parts for sale'
  end

  def seo_antique_autoparts_title
    'Classic car parts for sale online - buy auto parts at auction in USA'
  end

  def seo_antique_autoparts_h1
    'Classic car parts for sale'
  end

  def seo_new_autoparts_title
    'Buy cheap new auto parts at auction in USA'
  end

  def seo_new_autoparts_h1
    'Buy cheap new auto parts'
  end

  ############## ELECTRONICS ###############

  def seo_electronics_title
    case seo_condition
    when 'used'
      seo_used_electronics_title
    when 'antique'
      seo_antique_electronics_title
    else
      'Sell cheap electronics online - buy at auction in USA'
    end
  end

  def seo_electronics_h1
    case seo_condition
    when 'used'
      seo_used_electronics_h1
    when 'antique'
      seo_antique_electronics_h1
    else
      'Sell and buy cheap electronics'
    end
  end

  def seo_antique_electronics_title
    'Antique electronics for sale at auction in USA'
  end

  def seo_antique_electronics_h1
    'Antique electronics for sale'
  end

  def seo_used_electronics_title
    'Used electronics for sale at auction in USA'
  end

  def seo_used_electronics_h1
    'Used electronics for sale'
  end

  ############## DIY & CRAFTS ###############

  def seo_diy_crafts_title
    'Craft supplies online - buy and sale handmade crafts at auction in USA'
  end

  def seo_diy_crafts_h1
    'Craft and handmade supplies'
  end

  ############## GADGETS ###############

  def seo_gadgets_title
    case seo_condition
    when 'used'
      seo_used_gadgets_title
    when 'new'
      seo_new_gadgets_title
    else
      'Cheap gadgets for sale - buy at auction in USA'
    end
  end

  def seo_gadgets_h1
    case seo_condition
    when 'used'
      seo_used_gadgets_h1
    when 'new'
      seo_new_gadgets_h1
    else
      'Cheap gadgets for sale'
    end
  end

  def seo_new_gadgets_title
    'New gadgets for sale - buy at auction in USA'
  end

  def seo_new_gadgets_h1
    'New gadgets for sale'
  end

  def seo_used_gadgets_title
    'Buy and sale used gadgets at auction in USA'
  end

  def seo_used_gadgets_h1
    'Used gadgets for sale'
  end

  ############## SPORT ###############

  def seo_sports_title
    case seo_condition
    when 'used'
      seo_used_sports_title
    else
      'Sporting goods for sale - buy at auction in USA'
    end
  end

  def seo_sports_h1
    case seo_condition
    when 'used'
      seo_used_sports_h1
    else
      'Sporting goods for sale'
    end
  end

  def seo_used_sports_title
    'Used sporting goods for sale - buy at auction in USA'
  end

  def seo_used_sports_h1
    'Used sporting goods for sale'
  end

  ############## ART ###############

  def seo_art_title
    case seo_condition
    when 'antique'
      seo_antique_art_title
    else
      'Art work for sale at auction in USA'
    end
  end

  def seo_art_h1
    case seo_condition
    when 'antique'
      seo_antique_art_h1
    else
      'Art work for sale'
    end
  end

  def seo_antique_art_title
    'Antique art work for sale at auction in USA'
  end

  def seo_antique_art_h1
    'Antique art work for sale'
  end

  ############## HOME ###############

  def seo_home_title
    case seo_condition
    when 'antique'
      seo_antique_home_title
    when 'used'
      seo_used_home_title
    else
      'Home decor - buy and sale home decor at auction in USA'
    end
  end

  def seo_home_h1
    case seo_condition
    when 'antique'
      seo_antique_home_h1
    when 'used'
      seo_used_home_h1
    else
      'Home decor for sale'
    end
  end

  def seo_antique_home_title
    'Vintage home decor - buy and sale antique home decor at auction in USA'
  end

  def seo_antique_home_h1
    'Vintage home decor'
  end

  def seo_used_home_title
    'Used home decor and furniture for sale at auction in USA'
  end

  def seo_used_home_h1
    'Used home decor and furniture for sale'
  end
end
