module BettertabsHelper

  # bettertabs(bettertabs_id, options={})
  # Bettertabs helper that generates tabs and content markup.
  #
  # === Example
  #     = bettertabs :bettertabs_id do |tab|
  #       - tab.link :tab1_id, 'Tab1', options1
  #       - tab.static :tab2_id, 'Tab2', options2
  #       - tab.ajax :tab3_id, 'Tab3', options3
  #
  # === bettertabs params
  #   * bettertabs_id: will be used as html id of the wrapper element, and as part of the inner ids.
  #                     Note: is usually better to use a Symbol (with underscores) here to avoid problems defining routes.
  #   * options:
  #       * :selected_tab => tab_id of the default selected tab.
  #                       This is overriden by the appropiate param params[:"#{bettertabs_id}_selected_tab"], 
  #                       so any tab can be selected using the URL parmas. 
  #                       :selected_tab only defines which tab is selected when no {bettertabs_id}_selected_tab param is present.
  #       * :render_only_active_content => if true, this helper renders only the selected tab contents (no wrapper, no tabs, only content).
  #                       Default to true only if controller.request.xhr? or params[:ajax].present? (true when its an ajax request).
  #       * :attach_jquery_bettertabs_inline => this helper includes a little inline script to apply the Bettertabs jQuery plugin to this widget. If false, do not render that inline script.
  #       * :class => html class attribute of the wrapper element. By default is 'bettertabs'
  #       * :id => html id attribute of the wrapper element. By default is the bettertabs_id
  #       * Any other option will be used as wrapper elmenet html attribute.
  #
  # ==== tab builder params
  # Tab builder descriptor:
  #     tab.link(tab_id, options={}, &block)
  #     tab.link(tab_id, tab_text, options={}, &block)
  #
  # Params:
  #   * tab_id: the tab item html id will be "#{tab_id}_#{bettertabs_id}_tab", 
  #                     and the content wrapper id will be "#{tab_id}_#{bettertabs_id}_content".
  #                     Also the tab_id is used to identify this tab in the bettertabs :selected_tab option.
  #   * tab_text: is the content of the tab link. Defaults to tab_id.to_s.titleize
  #   * options:
  #       * :partial => Partial to render as content. Defaults to *tab_id*, but if &block given it captures the block instead of render partial.
  #                     If you need to suply locals to the partial, use a block with a render(:partial => partial, :locals => {locals}) call.
  #       * :url => href of the tab link. For link tabs, this is the href to go when click.
  #                 For ajax and static tabs, this is the url to replace in the browser when click (HTML5 history.replaceState()), and also the url
  #                 to use if JavaSciprt is disabled. 
  #                 Defaults to { :"#{bettertabs_id}_selected_tab" => tab_id }, that is the current URL plus the selected tab param.
  #       * :ajax_url => used as data-ajax-url html5 attribute in the link tab, that will be used in the jquery.bettertabs plugin as ajax href where to
  #                 make the ajax request to get the tab content.
  #                 By default is the same as the provided :url option, plus the { :ajax => true } param.
  #                 Note: This extra param makes the :url and :ajax_url different for the browser and prevents a cache mistake,
  #                 otherwise the browser may fetch the url cache with the ajax response, producing a bug when visiting again the same page.
  #
  def bettertabs(bettertabs_id, options={})
    bettertabs_id = bettertabs_id.to_s
    selected_tab_id = params[:"#{bettertabs_id}_selected_tab"] || options.delete(:selected_tab)
    options[:class] ||= "bettertabs"
    options[:id] ||= bettertabs_id
    options[:render_only_active_content] = controller.request.xhr? unless options.include?(:render_only_active_content)
    attach_jquery_bettertabs_inline = options.include?(:attach_jquery_bettertabs_inline) ? options.delete(:attach_jquery_bettertabs_inline) : true
    options[:after_tabs_content] = content_for(:"after_#{bettertabs_id}")
    builder = BettertabsBuilder.new(bettertabs_id, self, selected_tab_id, options)
    yield(builder)
    b = builder.render
    b += javascript_tag("jQuery(function($){ $('##{options[:id]}').bettertabs(); });") if attach_jquery_bettertabs_inline
    b
  end
  
end