module PaginationHelper
  def will_paginate(collection = nil, options = {})
    defaults = {
      renderer: 'WillPaginate::ActionView::PatternflyLinkRenderer',
      page_links: false,
      container: false,
      outer_window: 0,
      previous_label: icon_text('angle-left', '', kind: 'fa'),
      next_label: icon_text('angle-right', '', kind: 'fa'),
      last_label: icon_text('angle-double-right', '', kind: 'fa'),
      first_label: icon_text('angle-double-left', '', kind: 'fa')
    }
    super(collection, defaults.merge(options))
  end

  def will_paginate_with_info(collection = nil, options = {})
    content_tag(:form,
                id: 'pagination',
                class: 'content-view-pf-pagination table-view-pf-pagination clearfix',
                data: {
                  'count' => collection.total_entries,
                  'per-page' => per_page(collection)
                }) do
      render('common/pagination', collection: collection, options: options)
    end
  end

  def per_page_options(options = [5, 10, 15, 25, 50])
    options << Setting[:entries_per_page].to_i
    options << params[:per_page].to_i unless params[:per_page].blank?
    options.uniq.sort
  end
end
