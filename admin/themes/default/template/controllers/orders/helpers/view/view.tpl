{*
* 2007-2017 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2017 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}

{extends file="helpers/view/view.tpl"}
{extends file="page_header_toolbar.tpl"}
{block name=pageTitle}
    <h2 class="order_page_title page-title">
        {if is_array($title)}{$title|end|strip_tags}{else}{$title|strip_tags}{/if}
        {if $currentState == Configuration::get('PS_OS_REFUND')}
            <span class="toolbar_badge badge badge-danger">{l s='Refunded'}</span>
        {elseif $currentState == Configuration::get('PS_OS_CANCELED')}
            <span class="toolbar_badge badge badge-danger">{l s='Cancelled'}</span>
        {else}
            <span class="toolbar_badge badge badge-success">{l s='Booked'}</span>
        {/if}
    </h2>
{/block}

{block name="override_tpl"}
	<script type="text/javascript">
	var admin_order_tab_link = "{$link->getAdminLink('AdminOrders')|addslashes}";
	var id_order = {$order->id};
	var id_lang = {$current_id_lang};
	var id_currency = {$order->id_currency};
	var id_customer = {$order->id_customer|intval};
	{assign var=PS_TAX_ADDRESS_TYPE value=Configuration::get('PS_TAX_ADDRESS_TYPE')}
	var id_address = {$order->$PS_TAX_ADDRESS_TYPE};
	var currency_sign = "{$currency->sign}";
	var currency_format = "{$currency->format}";
	var currency_blank = "{$currency->blank}";
	var priceDisplayPrecision = {$smarty.const._PS_PRICE_DISPLAY_PRECISION_|intval};
	var use_taxes = {if $order->getTaxCalculationMethod() == $smarty.const.PS_TAX_INC}true{else}false{/if};
	var stock_management = {$stock_management|intval};
	var txt_add_product_stock_issue = "{l s='Are you sure you want to add this quantity?' js=1}";
	var txt_add_product_new_invoice = "{l s='Are you sure you want to create a new invoice?' js=1}";
	var txt_add_product_no_product = "{l s='Error: No product has been selected' js=1}";
	var txt_add_product_no_product_quantity = "{l s='Error: Quantity of products must be set' js=1}";
	var txt_add_product_no_product_price = "{l s='Error: Product price must be set' js=1}";
	var txt_confirm = "{l s='Are you sure?' js=1}";
	var statesShipped = new Array();
	var has_voucher = {if count($discounts)}1{else}0{/if};
	{foreach from=$states item=state}
		{if (isset($currentState->shipped) && !$currentState->shipped && $state['shipped'])}
			statesShipped.push({$state['id_order_state']});
		{/if}
	{/foreach}
	var order_discount_price = {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
									{$order->total_discounts_tax_excl}
								{else}
									{$order->total_discounts_tax_incl}
								{/if};

	var errorRefund = "{l s='Error. You cannot refund a negative amount.'}";
	</script>

	{assign var="hook_invoice" value={hook h="displayInvoice" id_order=$order->id}}
	{if ($hook_invoice)}
	<div>{$hook_invoice}</div>
	{/if}

    <div id="order_detail_view">
        <div class="panel kpi-container">
            <div class="row">
                <div class="col-xs-6 col-sm-3 box-stats color3" >
                    <div class="kpi-content">
                        <i class="icon-calendar-empty"></i>
                        <span class="title">{l s='Date'}</span>
                        <span class="value">{dateFormat date=$order->date_add full=false}</span>
                    </div>
                </div>
                <div class="col-xs-6 col-sm-3 box-stats color4" >
                    <div class="kpi-content">
                        <i class="icon-money"></i>
                        <span class="title">{l s='Total'}</span>
                        <span class="value">{displayPrice price=$order->total_paid_tax_incl currency=$currency->id}</span>
                    </div>
                </div>
                <div class="col-xs-6 col-sm-3 box-stats color2" >
                    <div class="kpi-content">
                        <i class="icon-comments"></i>
                        <span class="title">{l s='Messages'}</span>
                        <span class="value"><a href="{$link->getAdminLink('AdminCustomerThreads')|escape:'html':'UTF-8'}&amp;id_order={$order->id|intval}">{sizeof($customer_thread_message)}</a></span>
                    </div>
                </div>
                <div class="col-xs-6 col-sm-3 box-stats color1" >
                    <a href="#start_products">
                        <div class="kpi-content">
                            <i class="icon icon-home"></i>
                            <!-- Original -->
                            <!-- <span class="title">{l s='Total'}</span>
                            <span class="value">{sizeof($products)}</span> -->
                            <span class="title">{l s='Total Rooms'}</span>
                            <span class="value">{$order_detail_data|@count}</span>
                        </div>
                    </a>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-7">
                <div class="panel order-panel">
                    <div class="panel-heading order_status_heading">
                        <i class="icon-bed"></i> &nbsp;{l s='Rooms Status'}
                    </div>
                    <div class="panel-content">
                        <div class="row">
                            <div class="col-lg-12 table-responsive" id="room_status_info_wrapper">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>{l s='Room No.'}</th>
                                            <th>{l s='Hotel Name'}</th>
                                            <th>{l s='Duration'}</th>
                                            <th>{l s='Documents'}</th>
                                            <th>{l s='Order Status'}</th>
                                            <th>{l s='Action'}</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {if isset($htl_booking_order_data) && $htl_booking_order_data}
                                            {foreach from=$htl_booking_order_data item=data}
                                                {if !$data.is_refunded}
                                                    <tr>
                                                        <td>
                                                            {$data['room_num']}
                                                        </td>
                                                        <td>
                                                            <a class="order_detail_link" href="{$link->getAdminLink('AdminAddHotel')}&amp;id={$data['id_hotel']}&amp;updatehtl_branch_info" target="_blank">
                                                                <span>{$data['hotel_name']}</span>
                                                            </a>
                                                        </td>
                                                        <td>
                                                            {dateFormat date=$data['date_from']} - {dateFormat date=$data['date_to']}
                                                        </td>
                                                        <td>
                                                            <a href="#" class="text-bold order_detail_link" onclick="BookingDocumentsModal.init({$data.id|intval}, this); return false;">
                                                                {if $data.num_checkin_documents > 0}{$data.num_checkin_documents}{else}{l s='Upload'}{/if} {l s='Documents'}
                                                            </a>
                                                        </td>
                                                        <td>
                                                            {if $data['id_status'] == $hotel_order_status['STATUS_ALLOTED']['id_status']}
                                                                {l s='Alloted'}
                                                            {elseif $data['id_status'] == $hotel_order_status['STATUS_CHECKED_IN']['id_status']}
                                                                <span class="text-danger">{l s='Checked in on'} {dateFormat date=$data['check_in']}</span>
                                                            {elseif $data['id_status'] == $hotel_order_status['STATUS_CHECKED_OUT']['id_status']}
                                                                <span class="text-success">{l s='Checked out on'} {dateFormat date=$data['check_out']}</span>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <a class="open_room_status_form order_detail_link" href="#" data-id_order="{$data['id_order']}" data-id_status="{$data['id_status']}" data-id_room="{$data['id_room']}" data-date_from="{$data['date_from']|date_format:"%Y-%m-%d"}" data-date_to="{$data['date_to']|date_format:"%Y-%m-%d"}">
                                                                {l s='Edit Status'}
                                                            </a>
                                                        </td>
                                                    </tr>
                                                {/if}
                                            {/foreach}
                                        {else}
                                            <tr>
                                                <td class="list-empty hidden-print" colspan="6">
                                                    <div class="list-empty-msg">
                                                        <i class="icon-warning-sign list-empty-icon"></i>
                                                        {l s='No rooms found'}
                                                    </div>
                                                </td>
                                            </tr>
                                        {/if}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-file"></i> &nbsp;{l s='Order'}
                        <span class="badge">{$order->reference}</span>
                        <span class="badge">{l s="#"}{$order->id}</span>
                        <div class="panel-heading-action">
                            <div class="btn-group">
                                <a class="btn btn-default{if !$previousOrder} disabled{/if}" href="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$previousOrder|intval}">
                                    <i class="icon-backward"></i>
                                </a>
                                <a class="btn btn-default{if !$nextOrder} disabled{/if}" href="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$nextOrder|intval}">
                                    <i class="icon-forward"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                    <!-- Tab nav -->
                    <ul class="nav nav-tabs" id="tabOrder">
                        {$HOOK_TAB_ORDER}
                        <li class="active">
                            <a class="order_detail_link" href="#status">
                                <i class="icon-time"></i>
                                {l s='Status'} <span class="badge">{$history|@count}</span>
                            </a>
                        </li>
                        <li>
                            <a class="order_detail_link" href="#documents">
                                <i class="icon-file-text"></i>
                                {l s='Documents'} <span class="badge">{$order->getDocuments()|@count}</span>
                            </a>
                        </li>
                    </ul>
                    <!-- Tab content -->
                    <div class="tab-content panel">
                        {$HOOK_CONTENT_ORDER}
                        <!-- Tab status -->
                        <div class="tab-pane active" id="status">
                            <h4 class="visible-print">{l s='Status'} <span class="badge">({$history|@count})</span></h4>
                            <!-- History of status -->
                            <div class="table-responsive">
                                <table class="table history-status row-margin-bottom">
                                    <tbody>
                                        {foreach from=$history item=row key=key}
                                            {if ($key == 0)}
                                                <tr>
                                                    <td style="border-width: 1px 0px 1px 1px; border-color: {$row['color']}; border-style: solid"><img src="{$link->getMediaLink("`$img_dir`os/`$row['id_order_state']|intval`.gif")}" width="16" height="16" alt="{$row['ostate_name']|stripslashes}" /></td> {* by webkul to get media link *}
                                                    <td style="border-width: 1px 0px 1px 0px; border-color: {$row['color']}; border-style: solid">{$row['ostate_name']|stripslashes}</td>
                                                    <td style="border-width: 1px 0px 1px 0px; border-color: {$row['color']}; border-style: solid">{if $row['employee_lastname']}{$row['employee_firstname']|stripslashes} {$row['employee_lastname']|stripslashes}{/if}</td>
                                                    <td style="border-width: 1px 0px 1px 0px; border-color: {$row['color']}; border-style: solid">{dateFormat date=$row['date_add'] full=true}</td>
                                                    <td style="border-width: 1px 1px 1px 0px; border-color: {$row['color']}; border-style: solid" class="text-right">
                                                        {if $row['send_email']|intval}
                                                            <a class="order_detail_link" href="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}&amp;sendStateEmail={$row['id_order_state']|intval}&amp;id_order_history={$row['id_order_history']|intval}" title="{l s='Resend this email to the customer'}">
                                                                <i class="icon-mail-reply"></i>
                                                                {l s='Resend email'}
                                                            </a>
                                                        {/if}
                                                    </td>
                                                </tr>
                                            {else}
                                                <tr>
                                                    <td><img src="{$link->getMediaLink("`$img_dir`os/`$row['id_order_state']|intval`.gif")}" width="16" height="16" /></td>
                                                    <td>{$row['ostate_name']|stripslashes}</td>
                                                    <td>{if $row['employee_lastname']}{$row['employee_firstname']|stripslashes} {$row['employee_lastname']|stripslashes}{else}&nbsp;{/if}</td>
                                                    <td>{dateFormat date=$row['date_add'] full=true}</td>
                                                    <td class="text-right">
                                                        {if $row['send_email']|intval}
                                                            <a class="order_detail_link" href="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}&amp;sendStateEmail={$row['id_order_state']|intval}&amp;id_order_history={$row['id_order_history']|intval}" title="{l s='Resend this email to the customer'}">
                                                                <i class="icon-mail-reply"></i>
                                                                {l s='Resend email'}
                                                            </a>
                                                        {/if}
                                                    </td>
                                                </tr>
                                            {/if}
                                        {/foreach}
                                    </tbody>
                                </table>
                            </div>
                            <!-- Change status form -->
                            <form action="{$currentIndex|escape:'html':'UTF-8'}&amp;vieworder&amp;token={$smarty.get.token}" method="post" class="form-horizontal well hidden-print order_status_form">
                                <div class="row">
                                    <div class="col-lg-9">
                                        <select id="id_order_state" class="chosen form-control" name="id_order_state">
                                            {foreach from=$states item=state}
                                                <option value="{$state['id_order_state']|intval}"{if isset($currentState) && $state['id_order_state'] == $currentState->id} selected="selected" disabled="disabled"{/if}>{$state['name']|escape}</option>
                                            {/foreach}
                                        </select>
                                        <input type="hidden" name="id_order" value="{$order->id}" />
                                    </div>
                                    <div class="col-lg-3">
                                        <button type="submit" name="submitState" class="btn btn-primary">
                                            {l s='Update status'}
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <!-- Tab documents -->
                        <div class="tab-pane" id="documents">
                            <h4 class="visible-print">{l s='Documents'} <span class="badge">({$order->getDocuments()|@count})</span></h4>
                            {* Include document template *}
                            {include file='controllers/orders/_documents.tpl'}
                        </div>
                    </div>
                    <script>
                        $('#tabOrder a').click(function (e) {
                            e.preventDefault()
                            $(this).tab('show')
                        })
                    </script>
                    <hr />
                    <!-- Tab nav -->
                    <ul class="nav nav-tabs" id="myTab" style="display:none"><!-- by webkul -->
                        {$HOOK_TAB_SHIP}
                        <li class="active">
                            <a href="#shipping">
                                <i class="icon-truck "></i>
                                {l s='Shipping'} <span class="badge">{$order->getShipping()|@count}</span>
                            </a>
                        </li>
                        <li>
                            <a href="#returns">
                                <i class="icon-undo"></i>
                                {l s='Merchandise Returns'} <span class="badge">{$order->getReturn()|@count}</span>
                            </a>
                        </li>
                    </ul>
                    <!-- Tab content -->
                    <div class="tab-content panel" style="display:none"><!-- by webkul -->
                    {$HOOK_CONTENT_SHIP}
                        <!-- Tab shipping -->
                        <div class="tab-pane active" id="shipping">
                            <h4 class="visible-print">{l s='Shipping'} <span class="badge">({$order->getShipping()|@count})</span></h4>
                            <!-- Shipping block -->
                            {if !$order->isVirtual()}
                            <div class="form-horizontal">
                                {if $order->gift_message}
                                <div class="form-group">
                                    <label class="control-label col-lg-3">{l s='Message'}</label>
                                    <div class="col-lg-9">
                                        <p class="form-control-static">{$order->gift_message|nl2br}</p>
                                    </div>
                                </div>
                                {/if}
                                {include file='controllers/orders/_shipping.tpl'}
                                {if $carrierModuleCall}
                                    {$carrierModuleCall}
                                {/if}
                                <hr />
                                {if $order->recyclable}
                                    <span class="label label-success"><i class="icon-check"></i> {l s='Recycled packaging'}</span>
                                {else}
                                    <span class="label label-inactive"><i class="icon-remove"></i> {l s='Recycled packaging'}</span>
                                {/if}

                                {if $order->gift}
                                    <span class="label label-success"><i class="icon-check"></i> {l s='Gift wrapping'}</span>
                                {else}
                                    <span class="label label-inactive"><i class="icon-remove"></i> {l s='Gift wrapping'}</span>
                                {/if}
                            </div>
                            {/if}
                        </div>
                        <!-- Tab returns -->
                        <div class="tab-pane" id="returns">
                            <h4 class="visible-print">{l s='Merchandise Returns'} <span class="badge">({$order->getReturn()|@count})</span></h4>
                            {if !$order->isVirtual()}
                            <!-- Return block -->
                                {if $order->getReturn()|count > 0}
                                <div class="table-responsive">
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th><span class="title_box ">{l s='Date'}</span></th>
                                                <th><span class="title_box ">{l s='Type'}</span></th>
                                                <th><span class="title_box ">{l s='Carrier'}</span></th>
                                                <th><span class="title_box ">{l s='Tracking number'}</span></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {foreach from=$order->getReturn() item=line}
                                            <tr>
                                                <td>{$line.date_add}</td>
                                                <td>{l s=$line.type}</td>
                                                <td>{$line.state_name}</td>
                                                <td class="actions">
                                                    <span class="shipping_number_show">{if isset($line.url) && isset($line.tracking_number)}<a href="{$line.url|replace:'@':$line.tracking_number|escape:'html':'UTF-8'}">{$line.tracking_number}</a>{elseif isset($line.tracking_number)}{$line.tracking_number}{/if}</span>
                                                    {if $line.can_edit}
                                                    <form method="post" action="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}&amp;id_order_invoice={if $line.id_order_invoice}{$line.id_order_invoice|intval}{else}0{/if}&amp;id_carrier={if $line.id_carrier}{$line.id_carrier|escape:'html':'UTF-8'}{else}0{/if}">
                                                        <span class="shipping_number_edit" style="display:none;">
                                                            <button type="button" name="tracking_number">
                                                                {$line.tracking_number|htmlentities}
                                                            </button>
                                                            <button type="submit" class="btn btn-default" name="submitShippingNumber">
                                                                {l s='Update'}
                                                            </button>
                                                        </span>
                                                        <button href="#" class="edit_shipping_number_link">
                                                            <i class="icon-pencil"></i>
                                                            {l s='Edit'}
                                                        </button>
                                                        <button href="#" class="cancel_shipping_number_link" style="display: none;">
                                                            <i class="icon-remove"></i>
                                                            {l s='Cancel'}
                                                        </button>
                                                    </form>
                                                    {/if}
                                                </td>
                                            </tr>
                                            {/foreach}
                                        </tbody>
                                    </table>
                                </div>
                                {else}
                                <div class="list-empty hidden-print">
                                    <div class="list-empty-msg">
                                        <i class="icon-warning-sign list-empty-icon"></i>
                                        {l s='No merchandise returned yet'}
                                    </div>
                                </div>
                                {/if}
                                {if $carrierModuleCall}
                                    {$carrierModuleCall}
                                {/if}
                            {/if}
                        </div>
                    </div>
                    <script>
                        $('#myTab a').click(function (e) {
                            e.preventDefault()
                            $(this).tab('show')
                        })
                    </script>
                </div>
                <!-- Payments block -->
                <div id="form_add_payment_panel" class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-credit-card"></i> &nbsp;{l s="Payment"} <span class="badge">{$order->getOrderPayments()|@count}</span>
                    </div>
                    {if count($order->getOrderPayments()) > 0}
                        <p class="alert alert-danger"{if round($order->total_paid_tax_incl, 2) == round($total_paid, 2) || (isset($currentState) && $currentState->id == 6)} style="display: none;"{/if}>
                            {l s='Warning'}
                            <strong>{displayPrice price=$total_paid currency=$currency->id}</strong>
                            {l s='paid instead of'}
                            <strong class="total_paid">{displayPrice price=$order->total_paid_tax_incl currency=$currency->id}</strong>
                            {* {foreach $order->getBrother() as $brother_order}
                                {if $brother_order@first}
                                    {if count($order->getBrother()) == 1}
                                        <br />{l s='This warning also concerns order '}
                                    {else}
                                        <br />{l s='This warning also concerns the next orders:'}
                                    {/if}
                                {/if}
                                <a href="{$current_index}&amp;vieworder&amp;id_order={$brother_order->id}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}">
                                    #{'%06d'|sprintf:$brother_order->id}
                                </a>
                            {/foreach} *}
                        </p>
                    {/if}
                    <div class="form-group">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th><span class="title_box ">{l s='Date'}</span></th>
                                        <th><span class="title_box ">{l s='Payment method'}</span></th>
                                        <th><span class="title_box ">{l s='Payment source'}</span></th>
                                        <th><span class="title_box ">{l s='Transaction ID'}</span></th>
                                        <th><span class="title_box ">{l s='Amount'}</span></th>
                                        <th><span class="title_box ">{l s='Invoice'}</span></th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach from=$order_payment_detail item=payment}
                                        <tr>
                                            <td>{dateFormat date=$payment['date_add'] full=true}</td>
                                            <td>{$payment['payment_method']|escape:'html':'UTF-8'}</td>
                                            <td>{$payment_types[$payment['payment_type']]['name']|escape:'html':'UTF-8'}</td>
                                            <td>{$payment['transaction_id']|escape:'html':'UTF-8'}</td>
                                            <td>{displayPrice price=$payment['real_paid_amount'] currency=$payment['id_currency']}</td>
                                            <td>{if isset($payment['invoice_number'])}{$payment['invoice_number']}{else}--{/if}</td>
                                            <td class="actions">
                                                <a class="order_detail_link open_payment_information" href="#" data-card_number="{if $payment['card_number']}{$payment['card_number']}{else}{l s='Not defined'}{/if}"  data-card_brand="{if $payment['card_brand']}{$payment['card_brand']}{else}{l s='Not defined'}{/if}"  data-card_expiration="{if $payment['card_expiration']}{$payment['card_expiration']}{else}{l s='Not defined'}{/if}"  data-card_holder="{if $payment['card_holder']}{$payment['card_holder']}{else}{l s='Not defined'}{/if}" data-payment_date="{if $payment['date_add']}{$payment['date_add']}{else}{l s='Not defined'}{/if}" data-payment_method="{if $payment['payment_method']}{$payment['payment_method']}{else}{l s='Not defined'}{/if}" data-payment_source="{if $payment_types[$payment['payment_type']]['name']}{$payment_types[$payment['payment_type']]['name']}{else}{l s='Not defined'}{/if}" data-transaction_id="{if $payment['transaction_id']}{$payment['transaction_id']}{else}{l s='Not defined'}{/if}" data-amount="{if $payment['amount'] > 0}{displayPrice currency={$payment['id_currency']} price={$payment['amount']}}{else}{l s='Not defined'}{/if}" data-invoice_number="{if $payment['invoice_number']}{$payment['invoice_number']}{else}{l s='Not defined'}{/if}">{l s='Details'}</a>
                                            </td>
                                        </tr>
                                    {foreachelse}
                                        <tr>
                                            <td class="list-empty hidden-print" colspan="6">
                                                <div class="list-empty-msg">
                                                    <i class="icon-warning-sign list-empty-icon"></i>
                                                    {l s='No payment records'}
                                                </div>
                                            </td>
                                        </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="form-group">
                        <button class="btn btn-primary add_new_payment" id="add_new_payment">
                            <i class="icon-plus-sign"></i> {l s='Add new payment'}
                        </button>
                    </div>
                    {if (!$order->valid && sizeof($currencies) > 1)}
                        <form class="form-horizontal well" method="post" action="{$currentIndex|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}">
                            <div class="form-group">
                                <label class="control-label col-lg-2 col-md-3 text-left">{l s='Change currency'}</label>
                                <div class="col-lg-4 col-md-5">
                                    <select name="new_currency">
                                    {foreach from=$currencies item=currency_change}
                                        {if $currency_change['id_currency'] != $order->id_currency}
                                        <option value="{$currency_change['id_currency']}">{$currency_change['name']} - {$currency_change['sign']}</option>
                                        {/if}
                                    {/foreach}
                                    </select>
                                </div>
                                <div class="col-lg-6 col-md-4">
                                    <button type="submit" class="btn btn-primary" name="submitChangeCurrency"><i class="icon-refresh"></i> {l s='Change Currencly'}</button>
                                </div>
                            </div>
                            <p class="help-block">{l s='Do not forget to update your exchange rate before making this change.'}</p>
                        </form>
                    {/if}
                </div>
                {hook h="displayAdminOrderLeft" id_order=$order->id}
            </div>
            <div class="col-lg-5">
                {* Traveller information *}
                {if $customerGuestDetail}
                    <div class="panel order-panel">
                        <div class="panel-heading">
                            <i class="icon icon-user"></i> &nbsp;{l s='Traveller detail'}
                             {if $can_edit}
                                <button id="edit_guest_details" class="btn btn-primary pull-right" type="button" >
                                    <i class="icon-pencil"></i> {l s='Edit'}
                                </button>
                            {/if}
                        </div>
                        <div class="panel-content form-horizontal" id="customer-guest-details">
                            <div class="form-group">
                                <div class="col-sm-6">
                                    <label class="control-label">{l s='Gender'}</label>
                                    <div class="gender_name">{$customerGuestDetail->gender->name}</div>
                                </div>
                                <div class="col-sm-6">
                                    <label class="control-label">{l s='Name'}</label>
                                    <div class="guest_name">{$customerGuestDetail->firstname} {$customerGuestDetail->lastname}</div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-6">
                                    <label class="control-label">{l s='Email'}</label>
                                    <div class="guest_email"><a class="order_detail_link" href="mailto:{$customerGuestDetail->email}"><i class="icon-envelope-o"></i> {$customerGuestDetail->email}</a></div>
                                </div>
                                <div class="col-sm-6">
                                    <label class="control-label">{l s='Phone'}</label>
                                    <div class="guest_phone"><a class="order_detail_link" href="tel:{$customerGuestDetail->phone}"><i class="icon-phone"></i> {$customerGuestDetail->phone}</a></div>
                                </div>
                            </div>
                        </div>
                    </div>
                {/if}

                <!-- Customer informations -->
                <div class="panel order-panel panel-customer">
                    {if $customer->id}
                        <div class="panel-heading">
                            <i class="icon-user"></i> &nbsp;{l s='Customer'} <span class="badge">{l s='#'}{$customer->id}</span>
                            <a href="?tab=AdminCustomers&amp;id_customer={$customer->id}&amp;viewcustomer&amp;token={getAdminToken tab='AdminCustomers'}" class="pull-right">{l s='Customer Full Details'}</a>
                        </div>
                        <div class="row">
                            <div class="col-xs-12 customer_info">
                                {if ($customer->isGuest())}
                                    <p class="alert alert-warning">{l s='This booking has been created by a guest.'}</p>
                                    {if (!Customer::customerExists($customer->email))}
                                        <dl class="list-detail col-sm-12">
                                            <label class="label-title">{l s='Guest info'}</label>

                                            <dd><i class="icon-envelope"></i>  &nbsp;<b><a class="order_detail_link" href="mailto:{$customer->email}">{$customer->email}</a></b></dd>
                                            {if $addresses.invoice->phone_mobile || $addresses.invoice->phone}
                                                <dd><i class="icon-phone"></i>  &nbsp;<b><a class="order_detail_link" href="tel:{if $addresses.invoice->phone_mobile}{$addresses.invoice->phone_mobile}{else}{$addresses.invoice->phone}{/if}">{if $addresses.invoice->phone_mobile}{$addresses.invoice->phone_mobile}{else}{$addresses.invoice->phone}{/if}</a></b></dd>
                                            {/if}
                                        </dl>

                                        <form method="post" action="index.php?tab=AdminCustomers&amp;id_customer={$customer->id}&amp;id_order={$order->id|intval}&amp;token={getAdminToken tab='AdminCustomers'}">
                                            <input type="hidden" name="id_lang" value="{$order->id_lang}" />
                                            <input class="btn btn-primary" type="submit" name="submitGuestToCustomer" value="{l s='Transform this guest into a customer'}" />
                                            <p class="help-block">{l s='This feature will generate a random password and send an email to the customer.'}</p>
                                        </form>
                                    {else}
                                        <div class="alert alert-warning">
                                            {l s='A registered customer account has already claimed this email address'}
                                        </div>
                                    {/if}
                                {else}
                                    <dl class="list-detail col-sm-6">
                                        <label class="label-title">{l s='Customer'}</label>

                                        <dd><i class="icon-user"></i> &nbsp;<b><a class="order_detail_link" href="?tab=AdminCustomers&amp;id_customer={$customer->id}&amp;viewcustomer&amp;token={getAdminToken tab='AdminCustomers'}">{$customer->firstname} {$customer->lastname}</a></b></dd>
                                        <dd><i class="icon-envelope"></i>  &nbsp;<b><a class="order_detail_link" href="mailto:{$customer->email}">{$customer->email}</a></b></dd>
                                        {if $addresses.invoice->phone_mobile || $addresses.invoice->phone}
                                            <dd><i class="icon-phone"></i>  &nbsp;<b><a class="order_detail_link" href="tel:{if $addresses.invoice->phone_mobile}{$addresses.invoice->phone_mobile}{else}{$addresses.invoice->phone}{/if}">{if $addresses.invoice->phone_mobile}{$addresses.invoice->phone_mobile}{else}{$addresses.invoice->phone}{/if}</a></b></dd>
                                        {/if}
                                    </dl>
                                    <dl class="list-detail col-sm-6">
                                        <label class="label-title">{l s='Customer Info'}</label>

                                        <dd><b><i class="icon-calendar"></i> &nbsp; {$customer->date_add|date_format:"%d %b, %Y"}</b> ({l s='Member since'})</dd>
                                        <dd><b><i class="icon-list"></i> &nbsp; {$customerStats['nb_orders']|intval}</b> ({l s='Total valid order placed'})</dd>
                                        <dd><b><i class="icon-credit-card"></i> &nbsp; {displayPrice price=Tools::ps_round(Tools::convertPrice($customerStats['total_orders'], $currency), 2) currency=$currency->id}</b> ({l s='Total spent since registration'})</dd>
                                        {if Configuration::get('PS_B2B_ENABLE')}
                                            <dd><b>{$customer->siret}</b> ({l s='Siret'})</dd>
                                            <dd><b>{$customer->ape|date_format:"%d %b, %Y"}</b> ({l s='APE'})</dd>
                                        {/if}
                                    </dl>
                                {/if}
                            </div>

                            <div class="col-xs-12">
                                <div class="panel panel-sm">
                                    <div class="panel-heading">
                                        <i class="icon-eye-slash"></i> &nbsp;{l s='Private note'}
                                    </div>
                                    <form id="customer_note" class="form-horizontal" action="ajax.php" method="post" onsubmit="saveCustomerNote({$customer->id});return false;" >
                                        <div class="form-group">
                                            <div class="col-lg-12">
                                                <textarea name="note" id="noteContent" class="textarea-autosize" onkeyup="$(this).val().length > 0 ? $('#submitCustomerNote').removeAttr('disabled') : $('#submitCustomerNote').attr('disabled', 'disabled')">{$customer->note}</textarea>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-12">
                                                <button type="submit" id="submitCustomerNote" class="btn btn-primary pull-right" disabled="disabled">
                                                    <i class="icon-save"></i> {l s='Add Note'}
                                                </button>
                                            </div>
                                        </div>
                                        <span id="note_feedback"></span>
                                    </form>
                                </div>
                            </div>

                            <div class="col-xs-12">
                                {capture "TaxMethod"}
                                    {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                        {l s='Tax excluded'}
                                    {else}
                                        {l s='Tax included'}
                                    {/if}
                                {/capture}
                                <div class="alert alert-warning">
                                    {l s='For this customer group, prices are displayed as: [1]%s[/1]' sprintf=[$smarty.capture.TaxMethod] tags=['<strong>']}
                                    {if !$refund_allowed}
                                        <br/><strong>{l s='Refunds are disabled'}</strong>
                                    {/if}
                                </div>
                            </div>
                        </div>

                    {/if}
                    <!-- Tab nav -->
                    <div class="row" style="display:none">
                        <ul class="nav nav-tabs" id="tabAddresses">
                            <li class="active">
                                <a href="#addressShipping">
                                    <i class="icon-truck"></i>
                                    {l s='Shipping address'}
                                </a>
                            </li>
                            <li>
                                <a href="#addressInvoice">
                                    <i class="icon-file-text"></i>
                                    {l s='Invoice address'}
                                </a>
                            </li>
                        </ul>
                        <!-- Tab content -->
                        <div class="tab-content panel">
                            <!-- Tab status -->
                            <div class="tab-pane  in active" id="addressShipping">
                                <!-- Addresses -->
                                <h4 class="visible-print">{l s='Shipping address'}</h4>
                                {if !$order->isVirtual()}
                                <!-- Shipping address -->
                                    {if $can_edit}
                                        <form class="form-horizontal hidden-print" method="post" action="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}">
                                            <div class="form-group">
                                                <div class="col-lg-9">
                                                    <select name="id_address">
                                                        {foreach from=$customer_addresses item=address}
                                                        <option value="{$address['id_address']}"
                                                            {if $address['id_address'] == $order->id_address_delivery}
                                                                selected="selected"
                                                            {/if}>
                                                            {$address['alias']} -
                                                            {$address['address1']}
                                                            {$address['postcode']}
                                                            {$address['city']}
                                                            {if !empty($address['state'])}
                                                                {$address['state']}
                                                            {/if},
                                                            {$address['country']}
                                                        </option>
                                                        {/foreach}
                                                    </select>
                                                </div>
                                                <div class="col-lg-3">
                                                    <button class="btn btn-default" type="submit" name="submitAddressShipping"><i class="icon-refresh"></i> {l s='Change'}</button>
                                                </div>
                                            </div>
                                        </form>
                                    {/if}
                                    <div class="well">
                                        <div class="row">
                                            <div class="col-sm-6">
                                                <a class="btn btn-default pull-right" href="?tab=AdminAddresses&amp;id_address={$addresses.delivery->id}&amp;addaddress&amp;realedit=1&amp;id_order={$order->id}&amp;address_type=1&amp;token={getAdminToken tab='AdminAddresses'}&amp;back={$smarty.server.REQUEST_URI|urlencode}">
                                                    <i class="icon-pencil"></i>
                                                    {l s='Edit'}
                                                </a>
                                                {displayAddressDetail address=$addresses.delivery newLine='<br />'}
                                                {if $addresses.delivery->other}
                                                    <hr />{$addresses.delivery->other}<br />
                                                {/if}
                                            </div>
                                        </div>
                                    </div>
                                {/if}
                            </div>
                            <div class="tab-pane " id="addressInvoice">
                                <!-- Invoice address -->
                                <h4 class="visible-print">{l s='Invoice address'}</h4>
                                {if $can_edit}
                                    <form class="form-horizontal hidden-print" method="post" action="{$link->getAdminLink('AdminOrders')|escape:'html':'UTF-8'}&amp;vieworder&amp;id_order={$order->id|intval}">
                                        <div class="form-group">
                                            <div class="col-lg-9">
                                                <select name="id_address">
                                                    {foreach from=$customer_addresses item=address}
                                                    <option value="{$address['id_address']}"
                                                        {if $address['id_address'] == $order->id_address_invoice}
                                                        selected="selected"
                                                        {/if}>
                                                        {$address['alias']} -
                                                        {$address['address1']}
                                                        {$address['postcode']}
                                                        {$address['city']}
                                                        {if !empty($address['state'])}
                                                            {$address['state']}
                                                        {/if},
                                                        {$address['country']}
                                                    </option>
                                                    {/foreach}
                                                </select>
                                            </div>
                                            <div class="col-lg-3">
                                                <button class="btn btn-default" type="submit" name="submitAddressInvoice"><i class="icon-refresh"></i> {l s='Change'}</button>
                                            </div>
                                        </div>
                                    </form>
                                {/if}
                                <div class="well">
                                    <div class="row">
                                        <div class="col-sm-6">
                                            <a class="btn btn-default pull-right" href="?tab=AdminAddresses&amp;id_address={$addresses.invoice->id}&amp;addaddress&amp;realedit=1&amp;id_order={$order->id}&amp;address_type=2&amp;back={$smarty.server.REQUEST_URI|urlencode}&amp;token={getAdminToken tab='AdminAddresses'}">
                                                <i class="icon-pencil"></i>
                                                {l s='Edit'}
                                            </a>
                                            {displayAddressDetail address=$addresses.invoice newLine='<br />'}
                                            {if $addresses.invoice->other}
                                                <hr />{$addresses.invoice->other}<br />
                                            {/if}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <script>
                        $('#tabAddresses a').click(function (e) {
                            e.preventDefault()
                            $(this).tab('show')
                        })
                    </script>
                </div>

                {* Order Internal notes *}
                {if (sizeof($messages))}
                    <div class="panel order-panel">
                        <div class="panel-heading">
                            <i class="icon-undo"></i> &nbsp;{l s='Order Notes'}
                        </div>
                        <div class="panel-content">
                            {foreach from=$messages item=message}
                                <div class="message-body">
                                    <p class="message-item-text">
                                        {$message['message']|escape:'html':'UTF-8'|nl2br}
                                    </p>
                                    <p>
                                        {if ($message['elastname']|escape:'html':'UTF-8')}{$message['efirstname']|escape:'html':'UTF-8'}
                                            <span>{$message['elastname']|escape:'html':'UTF-8'}{else}{$message['cfirstname']|escape:'html':'UTF-8'} {$message['clastname']|escape:'html':'UTF-8'}</span>
                                        {/if},
                                        <span class="message-date">&nbsp;<i class="icon-calendar"></i>
                                            {dateFormat date=$message['date_add']}
                                        </span>
                                        {if ($message['private'] == 1)}
                                            <span class="badge badge-info">{l s='Private'}</span>
                                        {/if}
                                    </p>
                                </div>
                                {* {if ($message['is_new_for_me'])}
                                    <a class="new_message" title="{l s='Mark this message as \'viewed\''}" href="{$smarty.server.REQUEST_URI}&amp;token={$smarty.get.token}&amp;messageReaded={$message['id_message']}">
                                        <i class="icon-ok"></i>
                                    </a>
                                {/if} *}
                            {/foreach}
                        </div>
                    </div>
                {/if}

                <div class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-undo"></i> &nbsp;{l s='Refund Requests'}
                    </div>
                    <div class="panel-content">
                        {if is_array($returns) && count($returns)}
                            <div class=table-responsive>
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>{l s='Request ID'}</th>
                                            <th>{l s='Total Rooms'}</th>
                                            <th>{l s='Requested Date'}</th>
                                            <th>{l s='Status'}</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {foreach from=$returns item=return_info}
                                            <tr>
                                                <td>
                                                    <a class="order_detail_link" href="{$link->getAdminLink('AdminOrderRefundRequests')}&vieworder_return&id_order_return={$return_info.id_order_return}" target="_blank">#{$return_info.id_order_return}</a>
                                                </td>
                                                <td>
                                                    {$return_info.total_rooms|escape:'html':'UTF-8'}
                                                </td>
                                                <td>
                                                    {$return_info.date_add}
                                                </td>
                                                <td>
                                                    <span class="badge" style="background-color:{$return_info.state_color}">{$return_info.state_name}</span>
                                                    {if $return_info.refunded_amount > 0}
                                                        &nbsp;<span class="badge badge-success">{displayPrice price=$return_info.refunded_amount currency=$currency->id}</span>
                                                    {/if}
                                                </td>
                                            </tr>
                                        {/foreach}
                                    </tbody>
                                </table>
                            </div>
                        {else}
                            <div class="list-empty">
                                <div class="list-empty-msg">
                                    <i class="icon-warning-sign list-empty-icon"></i>
                                    {l s='No refund requests created.'}
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
                <div class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-remove-sign"></i> &nbsp;{l s='Cancellation Policies'}
                    </div>
                    <div class="panel-content">
                        {if is_array($applicable_refund_policies) && count($applicable_refund_policies)}
                            <ul>
                                {foreach from=$applicable_refund_policies item=$applicable_refund_policy}
                                    <li class="form-group">
                                        <a class="order_detail_link" href="{$link->getAdminLink('AdminOrderRefundRules')|escape:'html':'UTF-8'}&id_refund_rule={$applicable_refund_policy.id_refund_rule}&updatehtl_order_refund_rules" target="_blank">
                                            {$applicable_refund_policy.name|escape:'html':'UTF-8'} &nbsp;<i class="icon icon-external-link-square"></i>
                                        </a>
                                    </li>
                                {/foreach}
                            </ul>
                        {else}
                            <div class="list-empty">
                                <div class="list-empty-msg">
                                    <i class="icon-warning-sign list-empty-icon"></i>
                                    {l s='No cancellation policies applicable.'}
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
                {hook h="displayAdminOrderRight" id_order=$order->id}
            </div>
        </div>
        {hook h="displayAdminOrder" id_order=$order->id}
        <div class="row" id="start_products">
            <div class="col-lg-12">
                <form class="container-command-top-spacing" action="{$current_index}&amp;vieworder&amp;token={$smarty.get.token|escape:'html':'UTF-8'}&amp;id_order={$order->id|intval}" method="post" onsubmit="return orderDeleteProduct('{l s='This product cannot be returned.'}', '{l s='Quantity to cancel is greater than quantity available.'}');">
                    <input type="hidden" name="id_order" value="{$order->id}" />
                    <div style="display: none">
                        <input type="hidden" value="{$order->getWarehouseList()|implode}" id="warehouse_list" />
                    </div>
                    <div class="panel order-panel" id="refundForm">
                        <div class="panel-heading">
                            <i class="icon-shopping-cart"></i> &nbsp;{l s='Rooms Booking Detail'} <span class="badge">{$order_detail_data|@count}</span>
                            {if !$order->hasBeenDelivered()}
                                <button type="button" id="add_room" class="btn btn-primary pull-right">
                                    <i class="icon-plus-sign"></i>
                                    {l s='Add Rooms In Order'}
                                </button>
                            {/if}
                        </div>
                        {* by webkul this code is added for showing rooms information on the order detail page *}
                        {include file='controllers/orders/_rooms_informaion_table.tpl'}
                        <br>
                        {include file='controllers/orders/_service_products_table.tpl'}

                        {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                            <input type="hidden" name="TaxMethod" value="0">
                        {else}
                            <input type="hidden" name="TaxMethod" value="1">
                        {/if}
                    </div>
                </form>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-4 col-sm-6 col-xs-12 pull-right">
                <div class="panel order-panel panel-total">
                    <div class="table-responsive">
                        <table class="table">
                            {* Assign order price *}
                            {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)}
                                {assign var=order_product_price value=($order->total_products)}
                                {assign var=order_discount_price value=$order->total_discounts_tax_excl}
                                {assign var=order_wrapping_price value=$order->total_wrapping_tax_excl}
                                {assign var=order_shipping_price value=$order->total_shipping_tax_excl}
                            {else}
                                {assign var=order_product_price value=$order->total_products_wt}
                                {assign var=order_discount_price value=$order->total_discounts_tax_incl}
                                {assign var=order_wrapping_price value=$order->total_wrapping_tax_incl}
                                {assign var=order_shipping_price value=$order->total_shipping_tax_incl}
                            {/if}

                            {assign var=room_price_tax_excl value=$order->getTotalProductsWithoutTaxes(false, true)}
                            {assign var=room_price_tax_incl value=$order->getTotalProductsWithTaxes(false, true)}
                            {assign var=service_products_price_tax_excl value=$order->getTotalProductsWithoutTaxes(false, false, Product::SERVICE_PRODUCT_WITHOUT_ROOMTYPE)}
                            {assign var=service_products_price_tax_incl value=$order->getTotalProductsWithTaxes(false, false, Product::SERVICE_PRODUCT_WITHOUT_ROOMTYPE)}
                            {assign var=additional_service_price_tax_excl value=($order->getTotalProductsWithoutTaxes(false, false, Product::SERVICE_PRODUCT_WITH_ROOMTYPE) + $totalDemandsPriceTE)}
                            {assign var=additional_service_price_tax_incl value=($order->getTotalProductsWithTaxes(false, false, Product::SERVICE_PRODUCT_WITH_ROOMTYPE) + $totalDemandsPriceTI)}
                            {if $room_price_tax_excl}
                                <tr id="total_products">
                                    <td class="text-right">{l s='Total Rooms Cost (tax excl.)'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=$room_price_tax_excl currency=$currency->id}
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}
                            {if isset($additional_service_price_tax_excl) && $additional_service_price_tax_excl > 0}
                                <tr id="total_products">
                                    <td class="text-right">{l s='Total Extra services (tax excl.)'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=($additional_service_price_tax_excl - $totalConvenienceFeeTE) currency=$currency->id}
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}
                            {* {if $room_price_tax_excl}
                                <tr id="total_tax_order">
                                    <td class="text-right"><strong>{l s='Total Rooms Tax'}</strong></td>
                                    <td class="text-right nowrap">
                                        <strong>{displayPrice price=($room_price_tax_incl - $room_price_tax_excl) currency=$currency->id}</strong>
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}
                            {if isset($additional_service_price_tax_excl) && $additional_service_price_tax_excl > 0}
                                <tr id="total_tax_order">
                                    <td class="text-right"><strong>{l s='Extra services Tax'}</strong></td>
                                    <td class="text-right nowrap">
                                        <strong>{displayPrice price=($additional_service_price_tax_incl - $additional_service_price_tax_excl) currency=$currency->id}</strong>
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if} *}
                            {if $service_products_price_tax_excl}
                                <tr id="total_products">
                                    <td class="text-right">{l s='Total service products cost (tax excl.)'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=$service_products_price_tax_excl currency=$currency->id}
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}

                            <tr id="total_discounts" {if $order->total_discounts_tax_incl == 0}style="display: none;"{/if}>
                                <td class="text-right">{l s='Discounts'}</td>
                                <td class="amount text-right nowrap">
                                    -{displayPrice price=$order_discount_price currency=$currency->id}
                                </td>
                                <td class="partial_refund_fields current-edit" style="display:none;"></td>
                            </tr>
                            <tr id="total_wrapping" {if $order->total_wrapping_tax_incl == 0}style="display: none;"{/if}>
                                <td class="text-right">{l s='Wrapping'}</td>
                                <td class="amount text-right nowrap">
                                    {displayPrice price=$order_wrapping_price currency=$currency->id}
                                </td>
                                <td class="partial_refund_fields current-edit" style="display:none;"></td>
                            </tr>
                            {if isset($totalConvenienceFeeTI) && $totalConvenienceFeeTI > 0}
                                <tr id="total_products">
                                    <td class="text-right">{l s='Convenience Fee'}</td>
                                    <td class="amount text-right nowrap">
                                        {displayPrice price=$totalConvenienceFeeTE currency=$currency->id}
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}
                            {* {if ($order->getTaxCalculationMethod() == $smarty.const.PS_TAX_EXC)} *}
                                <tr id="total_taxes">
                                    <td class="text-right">{l s='Total Taxes'}
                                    </td>
                                    <td class="amount text-right nowrap" >{displayPrice price=($order->total_paid_tax_incl - $order->total_paid_tax_excl) currency=$currency->id}
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {* {/if} *}
                            <tr id="total_order">
                                <td class="text-right"><strong>{l s='Final Booking Total'}</strong></td>
                                <td class="amount text-right nowrap">
                                    <strong>{displayPrice price=$order->total_paid_tax_incl currency=$currency->id}</strong>
                                </td>
                                <td class="partial_refund_fields current-edit" style="display:none;"></td>
                            </tr>

                            {if isset($refundReqBookings) && $refundReqBookings}
                                <tr id="total_order">
                                    <td class="text-right"><strong>* {l s='Refunded Amount'}</strong></td>
                                    <td class="amount text-right nowrap">
                                        <strong>{displayPrice price=$refundedAmount currency=$currency->id}</strong>
                                    </td>
                                    <td class="partial_refund_fields current-edit" style="display:none;"></td>
                                </tr>
                            {/if}

                            {if $order->total_paid_tax_incl > $order->total_paid_real}
                                <tr>
                                    <td class="text-right"><strong>{l s='Due Amount'}</strong></td>
                                    <td class="amount text-right nowrap">
                                        <strong>
                                            {displayPrice currency=$order->id_currency price=($order->total_paid_tax_incl - $order->total_paid_real)}
                                        </strong>
                                    </td>
                                </tr>
                            {/if}
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-sm-6 col-xs-12 pull-right">
                <div class="panel order-panel panel-vouchers">
                    <div class="panel-heading">
                        <span><i class="icon-cart"></i> &nbsp;{l s='Voucher'}</span>
                        {if $can_edit}
                            <button id="add_voucher" class="btn btn-primary pull-right" type="button" >
                                <i class="icon-ticket"></i> {l s='Add new voucher'}
                            </button>
                        {/if}
                    </div>
                    <div class="panel-content">
                        {if sizeof($discounts)}
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>
                                                <span class="title_box ">{l s='Voucher name'}</span>
                                            </th>
                                            <th>
                                                <span class="title_box ">{l s='Value'}</span>
                                            </th>
                                            {if $can_edit}
                                                <th>
                                                    <span class="title_box ">{l s='Delete'}</span>
                                                </th>
                                            {/if}
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {foreach from=$discounts item=discount}
                                            <tr>
                                                <td>{$discount['name']}</td>
                                                <td>
                                                {if $discount['value'] != 0.00}
                                                    -
                                                {/if}
                                                {displayPrice price=$discount['value'] currency=$currency->id}
                                                </td>
                                                {if $can_edit}
                                                    <td>
                                                        <a class="order_detail_link" href="{$current_index}&amp;submitDeleteVoucher&amp;id_order_cart_rule={$discount['id_order_cart_rule']}&amp;id_order={$order->id}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}">{l s='Delete'}</a>
                                                    </td>
                                                {/if}
                                            </tr>
                                        {/foreach}
                                    </tbody>
                                </table>
                            </div>
                        {else}
                            <div class="list-empty">
                                <div class="list-empty-msg">
                                    <i class="icon-warning-sign list-empty-icon"></i>
                                    {l s='No vouchers created.'}
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-sm-6 col-xs-12 pull-right">
                <!-- linked orders block -->
                <div class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-cart"></i> &nbsp;{l s='Linked orders'}
                    </div>
                    <div class="panel-content">
                        {if count($order->getBrother()) > 0}
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>
                                                {l s='Order no. '}
                                            </th>
                                            <th>
                                                {l s='Status'}
                                            </th>
                                            <th>
                                                {l s='Amount'}
                                            </th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {foreach $order->getBrother() as $brother_order}
                                        <tr>
                                            <td>
                                                <a class="order_detail_link" href="{$current_index}&amp;vieworder&amp;id_order={$brother_order->id}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}">#{$brother_order->id}</a>
                                            </td>
                                            <td>
                                                {$brother_order->getCurrentOrderState()->name[$current_id_lang]}
                                            </td>
                                            <td>
                                                {displayPrice price=$brother_order->total_paid_tax_incl currency=$currency->id}
                                            </td>
                                            <td>
                                                <a class="order_detail_link" href="{$current_index}&amp;vieworder&amp;id_order={$brother_order->id}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}">
                                                    <i class="icon-eye-open"></i>
                                                    {l s='See the order'}
                                                </a>
                                            </td>
                                        </tr>
                                        {/foreach}
                                    </tbody>
                                </table>
                            </div>
                        {else}
                            <div class="list-empty">
                                <div class="list-empty-msg">
                                    <i class="icon-warning-sign list-empty-icon"></i>
                                    {l s='No linked orders available.'}
                                </div>
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-sm-6 col-xs-12">
                <div class="panel order-panel">
                    <div class="panel-heading">
                        <i class="icon-envelope"></i> &nbsp;{l s='Messages'} <span class="badge">{sizeof($customer_thread_message)}</span>
                        <a href="{$link->getAdminLink('AdminCustomerThreads')|escape:'html':'UTF-8'}&amp;id_order={$order->id|intval}" class="pull-right">{l s='Show all messages'}</a>
                    </div>
                    <div id="messages" class="hidden-print">
                        <form action="{$smarty.server.REQUEST_URI|escape:'html':'UTF-8'}&amp;token={$smarty.get.token|escape:'html':'UTF-8'}" method="post" onsubmit="if (getE('visibility').checked == true) return confirm('{l s='Do you want to send this message to the customer?'}');">
                            <div id="message" class="form-horizontal">
                                <div class="form-group">
                                    <label class="control-label">{l s='Choose a standard message'}</label>
                                    <p>
                                        <select class="chosen form-control" name="order_message" id="order_message" onchange="orderOverwriteMessage(this, '{l s='Do you want to overwrite your existing message?'}')">
                                            <option value="0" selected="selected">-</option>
                                            {foreach from=$orderMessages item=orderMessage}
                                            <option value="{$orderMessage['message']|escape:'html':'UTF-8'}">{$orderMessage['name']}</option>
                                            {/foreach}
                                        </select>
                                    </p>
                                    <div>
                                        <a class="order_detail_link" href="{$link->getAdminLink('AdminOrderMessage')|escape:'html':'UTF-8'}">
                                            {l s='Configure predefined messages'}
                                            <i class="icon-external-link"></i>
                                        </a>
                                    </div>
                                </div>

                                <div class="row">
                                    <label class="control-label">{l s='Message'}</label>
                                    <textarea rows="3" id="txt_msg" class="textarea-autosize" name="message">{Tools::getValue('message')|escape:'html':'UTF-8'}</textarea>
                                </div>

                               <div class="form-group">
                                    <p class="checkbox">
                                        <label class="control-label" for="visibility">
                                            <input type="checkbox" name="visibility" id="visibility" value="1" />
                                            {l s='Display Message to Customer?'}
                                        </label>
                                    </p>
                                </div>
                                <input type="hidden" name="id_order" value="{$order->id}" />
                                <input type="hidden" name="id_customer" value="{$order->id_customer}" />

                                <div class="row">
                                    <button type="submit" id="submitMessage" class="btn btn-primary pull-right" name="submitMessage">
                                        <i class="icon-paper-plane"></i> {l s='Send Message'}
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 col-sm-6 col-xs-12">
                <!-- Sources block -->
                {if !(sizeof($sources))}
                    <div class="panel order-panel">
                        <div class="panel-heading">
                            <i class="icon-globe"></i> &nbsp;{l s='Sources'} <span class="badge">{$sources|@count}</span>
                        </div>
                        <ul {if sizeof($sources) > 3}style="height: 200px; overflow-y: scroll;"{/if}>
                        {foreach from=$sources item=source}
                            <li class="form-group">
                                {l s='From'} {if $source['http_referer'] != ''}<a class="order_detail_link" href="{$source['http_referer']}">{parse_url($source['http_referer'], $smarty.const.PHP_URL_HOST)|regex_replace:'/^www./':''}</a>{else}-{/if} {l s='To'} <a class="order_detail_link" href="http://{$source['request_uri']}">{$source['request_uri']|truncate:100:'...'}</a> <br />
                                {if $source['keywords']}<b>{l s='Keywords'}</b>: {$source['keywords']}<br />{/if}
                                {dateFormat date=$source['date_add'] full=true}<br />
                            </li>
                        {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>
        </div>
    </div>

    {* MOdal for extra demands *}
    <div class="modal" tabindex="-1" role="dialog" id="rooms_type_extra_demands">
        <div class="modal-dialog" role="document">
            <div class="modal-content" id="room_extra_demand_content"></div>
        </div>
    </div>

    {strip}
        {addJsDefL name=no_rm_avail_txt}{l s='No rooms available.' js=1}{/addJsDefL}
        {addJsDefL name=slct_rm_err}{l s='Please select a room first.' js=1}{/addJsDefL}
        {addJsDefL name=txtExtraDemandSucc}{l s='Updated Successfully' js=1}{/addJsDefL}
        {addJsDefL name=atleastSelectTxt}{l s='Select at least one facility to update.' js=1}{/addJsDefL}

        {addJsDefL name=txtSomeErr}{l s='Some error occurred. Please try again.' js=1}{/addJsDefL}
        {addJsDefL name=txtDeleteSucc}{l s='Deleted successfully' js=1}{/addJsDefL}
        {addJsDefL name=txtInvalidDemandVal}{l s='Invalid demand value found' js=1}{/addJsDefL}
        {addJsDefL name='select_age_txt'}{l s='Select age' js=1}{/addJsDefL}
        {addJsDefL name='under_1_age'}{l s='Under 1' js=1}{/addJsDefL}
        {addJsDefL name='room_txt'}{l s='Room' js=1}{/addJsDefL}
        {addJsDefL name='rooms_txt'}{l s='Rooms' js=1}{/addJsDefL}
        {addJsDefL name='remove_txt'}{l s='Remove' js=1}{/addJsDefL}
        {addJsDefL name='adult_txt'}{l s='Adult' js=1}{/addJsDefL}
        {addJsDefL name='adults_txt'}{l s='Adults' js=1}{/addJsDefL}
        {addJsDefL name='child_txt'}{l s='Child' js=1}{/addJsDefL}
        {addJsDefL name='children_txt'}{l s='Children' js=1}{/addJsDefL}
        {addJsDefL name='below_txt'}{l s='Below' js=1}{/addJsDefL}
        {addJsDefL name='years_txt'}{l s='years' js=1}{/addJsDefL}
        {addJsDefL name='all_children_txt'}{l s='All Children' js=1}{/addJsDefL}
        {addJsDefL name='invalid_occupancy_txt'}{l s='Invalid occupancy(adults/children) found.' js=1}{/addJsDefL}
        {addJsDef max_child_age=$max_child_age|escape:'quotes':'UTF-8'}
        {addJsDef max_child_in_room=$max_child_in_room|escape:'quotes':'UTF-8'}

        {addJsDefL name=txt_booking_document_upload_success}{l s='Document uploaded successfully.' js=1}{/addJsDefL}
        {addJsDefL name=txt_booking_document_delete_confirm}{l s='Are you sure?' js=1}{/addJsDefL}
        {addJsDefL name=txt_booking_document_delete_success}{l s='Document deleted successfully.' js=1}{/addJsDefL}
    {/strip}

    {* Apply javascript for the page *}
    <script>
        $(document).ready(function() {
            {* toggle date input of check-in checkout dates as per status selected *}
            $(document).on('change', '.booking_order_status', function() {
                var status = $(this).val();
                if (status == '2' || status == '3') {
                    $(this).closest('.room_status_info_form').find('.room_status_date').closest('.form-group').show();
                } else {
                    $(this).closest('.room_status_info_form').find('.room_status_date').closest('.form-group').hide();
                }
            });

            {* open date picker for the date input of check-in checkout dates *}
            $(document).on('focus', '.room_status_date', function() {
                var dateFrom = $(this).closest('.room_status_info_form').find('[name="date_from"]').val();
                dateFrom = dateFrom.split("-");
                minDate = new Date($.datepicker.formatDate('yy-mm-dd', new Date(dateFrom[0], dateFrom[1] - 1, dateFrom[2])));

                var dateTo = $(this).closest('.room_status_info_form').find('[name="date_to"]').val();
                dateTo = dateTo.split("-");
                maxDate = new Date($.datepicker.formatDate('yy-mm-dd', new Date(dateTo[0], dateTo[1] - 1, dateTo[2])));

                $(this).datepicker({
                    dateFormat: 'dd-mm-yy',
                    minDate: minDate,
                    maxDate: maxDate,
                    dayNamesMin: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                });
            });

            {* open fancybox for extra demands *}
            $('.open_room_extra_services').on('click', function(e) {
                e.preventDefault();
                var idProduct = $(this).attr('id_product');
                var idOrder = $(this).attr('id_order');
                var idRoom = $(this).attr('id_room');
                var dateFrom = $(this).attr('date_from');
                var dateTo = $(this).attr('date_to');
                var idHtlBooking = $(this).attr('id_htl_booking');
                var orderEdit = 0;
                if($(this).closest('.product-line-row').find(".submitRoomChange").is(":visible") == true ) {
                    orderEdit = 1;
                }

                $.ajax({
                    type: 'POST',
                    headers: {
                        "cache-control": "no-cache"
                    },
                    url: admin_order_tab_link,
                    dataType: 'html',
                    cache: false,
                    data: {
                        id_room: idRoom,
                        id_product: idProduct,
                        id_order: idOrder,
                        date_from: dateFrom,
                        date_to: dateTo,
                        orderEdit: orderEdit,
                        action: 'getRoomTypeBookingDemands',
                        ajax: true
                    },
                    success: function(result) {
                        $('#room_extra_demand_content').html('');
                        $('#room_extra_demand_content').append(result);

                        $('#room_extra_demand_content #id_htl_booking').val(idHtlBooking);

                        $('#rooms_type_extra_demands').modal('show');
                    },
                });
            });

            $('#rooms_type_extra_demands').on('hidden.bs.modal', function (e) {
                location.reload();
            });

            {* when choose to add new facilities while additional facilities edit *}
            $(document).on('click', '#btn_new_room_demand', function() {
                $('.room_demands_container').show();
                $('#save_room_demands').show();
                $('#back_to_demands_btn').show();
                $('.room_ordered_demands').hide();
                $('#btn_new_room_demand').hide();
            });
            {* click on back button on created facilities while additional facilities edit *}
            $(document).on('click', '#back_to_demands_btn', function() {
                $('.room_ordered_demands').show();
                $('#btn_new_room_demand').show();
                $('.room_demands_container').hide();
                $('#save_room_demands').hide();
                $('#back_to_demands_btn').hide();
            });

            $(document).on('click', '#btn_new_room_service', function() {
                $('.room_services_container').show();
                $('#save_service_service').show();
                $('#back_to_service_btn').show();
                $('.room_ordered_services').hide();
                $('#btn_new_room_service').hide();
            });
            {* click on back button on created facilities while additional facilities edit *}
            $(document).on('click', '#back_to_service_btn', function() {
                $('.room_ordered_services').show();
                $('#btn_new_room_service').show();
                $('.room_services_container').hide();
                $('#save_service_service').hide();
                $('#back_to_service_btn').hide();
            });

            $(document).on('focusout', '#edit-room-booking-modal .room_ordered_services .qty', function(e) {
                var qty_wntd = $(this).val();
                if (qty_wntd == '' || !$.isNumeric(qty_wntd) || qty_wntd < 1) {
                    $(this).val(1);
                }
                updateAdditionalServices($(this));
            });

            $(document).on('focusout', '#edit-room-booking-modal #add_room_services_form .qty', function(e) {
                var qty_wntd = $(this).val();
                if (qty_wntd == '' || !$.isNumeric(qty_wntd) || qty_wntd < 1) {
                    $(this).val(1);
                }
            });

            function updateAdditionalServices(element)
            {
                var id_room_type_service_product_order_detail = $(element).data('id_room_type_service_product_order_detail');
                var qty = $(element).val();
                if ($.isNumeric(qty)) {
                    $.ajax({
                        type: 'POST',
                        headers: {
                            "cache-control": "no-cache"
                        },
                        url: "{$link->getAdminLink('AdminOrders')|addslashes}",
                        dataType: 'JSON',
                        cache: false,
                        data: {
                            id_room_type_service_product_order_detail: id_room_type_service_product_order_detail,
                            qty: qty,
                            action: 'updateRoomAdditionalServices',
                            ajax: true
                        },
                        success: function(jsonData) {
                            if (!jsonData.hasError) {
                                if (jsonData.service_panel) {
                                    $('#room_type_service_product_desc').replaceWith(jsonData.service_panel);
                                }
                                showSuccessMessage(txtExtraDemandSucc);
                            } else {
                                showErrorMessage(jsonData.errors);

                            }
                        }
                    });
                }

            }

            $(document).on('submit', '#add_room_services_form', function(e) {
                e.preventDefault();
                var form_data = new FormData(this);
                form_data.append('ajax', true);
                form_data.append('action', 'addRoomAdditionalServices');

                $.ajax({
                    type: 'POST',
                    headers: {
                        "cache-control": "no-cache"
                    },
                    url: "{$link->getAdminLink('AdminOrders')|addslashes}",
                    dataType: 'JSON',
                    cache: false,
                    data: form_data,
                    processData: false,
                    contentType: false,
                    success: function(jsonData) {
                        if (!jsonData.hasError) {
                            if (jsonData.service_panel) {
                                $('#room_type_service_product_desc').replaceWith(jsonData.service_panel);
                            }
                            showSuccessMessage(txtExtraDemandSucc);
                        } else {
                            showErrorMessage(jsonData.errors);

                        }
                    }
                });
            });

            {* // save room extra demand to the order *}
            $(document).on('click', '#save_room_demands', function(e) {
                e.preventDefault();

                var idHtlBooking = parseInt($('#edit_product .extra-services-container #id_htl_booking').val());
                if (idHtlBooking) {
                    var roomDemands = [];
                    // get the selected extra demands by customer
                    $(this).closest('#edit_product #room_type_demands_desc').find('input:checkbox.id_room_type_demand:checked').each(function () {
                        roomDemands.push({
                            'id_global_demand':$(this).val(),
                            'id_option': $(this).closest('.room_demand_block').find('.id_option').val()
                        });
                    });

                    if (roomDemands.length) {
                        $.ajax({
                            type: 'POST',
                            headers: {
                                "cache-control": "no-cache"
                            },
                            url: "{$link->getAdminLink('AdminOrders')|addslashes}",
                            dataType: 'JSON',
                            cache: false,
                            data: {
                                id_htl_booking: idHtlBooking,
                                room_demands: JSON.stringify(roomDemands),
                                action: 'EditRoomExtraDemands',
                                ajax: true
                            },
                            success: function(jsonData) {
                                if (jsonData.success) {
                                    showSuccessMessage(txtExtraDemandSucc);
                                    if (jsonData.facilities_panel) {
                                        $('#room_type_demands_desc').replaceWith(jsonData.facilities_panel);
                                    }
                                } else {
                                    showErrorMessage(txtSomeErr);
                                }
                            }
                        });
                    } else {
                        showErrorMessage(atleastSelectTxt);
                    }
                }
            });

            {* Delete ordered room booking demand *}
            $(document).on('click', '.del-order-room-demand', function(e) {
                e.preventDefault();
                if (confirm(txt_confirm)) {
                    var idBookingDemand = $(this).attr('id_booking_demand');
                    $currentItem = $(this);
                    if (idBookingDemand) {
                        $.ajax({
                            type: 'POST',
                            headers: {
                                "cache-control": "no-cache"
                            },
                            url: "{$link->getAdminLink('AdminOrders')|addslashes}",
                            dataType: 'JSON',
                            cache: false,
                            data: {
                                id_booking_demand: idBookingDemand,
                                action: 'DeleteRoomExtraDemand',
                                ajax: true
                            },
                            success: function(jsonData) {
                                if (jsonData.success) {
                                    showSuccessMessage(txtDeleteSucc);
                                    if (jsonData.facilities_panel) {
                                        $('#room_type_demands_desc').replaceWith(jsonData.facilities_panel);
                                    }
                                } else {
                                    showErrorMessage(txtSomeErr);
                                }
                            }
                        });
                    } else {
                        showErrorMessage(txtInvalidDemandVal);
                    }
                }
            });

            $(document).on('click', '.del_room_additional_service', function(e){
                e.preventDefault();
                if (confirm(txt_confirm)) {
                    var idServiceProductOrderDetail = $(this).data('id_room_type_service_product_order_detail');
                    $currentItem = $(this);
                    if (idServiceProductOrderDetail) {
                        $.ajax({
                            type: 'POST',
                            headers: {
                                "cache-control": "no-cache"
                            },
                            url: "{$link->getAdminLink('AdminOrders')|addslashes}",
                            dataType: 'JSON',
                            cache: false,
                            data: {
                                id_room_type_service_product_order_detail: idServiceProductOrderDetail,
                                action: 'DeleteRoomAdditionalService',
                                ajax: true
                            },
                            success: function(jsonData) {
                                if (!jsonData.hasError) {
                                    if (jsonData.service_panel) {
                                        $('#room_type_service_product_desc').replaceWith(jsonData.service_panel);
                                    }
                                    showSuccessMessage(txtExtraDemandSucc);
                                } else {
                                    showErrorMessage(jsonData.errors);

                                }
                            }
                        });
                    } else {
                        showErrorMessage(txtInvalidDemandVal);
                    }
                }

            });

            // change advance option of extra demand
            $(document).on('change', '.demand_adv_option_block .id_option', function(e) {
                var option_selected = $(this).find('option:selected');
                var extra_demand_price = option_selected.attr("optionPrice")
                extra_demand_price = parseFloat(extra_demand_price);
                extra_demand_price = formatCurrency(extra_demand_price, currency_format, currency_sign, currency_blank);
                $(this).closest('.room_demand_block').find('.extra_demand_option_price').text(extra_demand_price);
            });

            $(".textarea-autosize").autosize();

            var date = new Date();
            var hours = date.getHours();
            if (hours < 10)
                hours = "0" + hours;
            var mins = date.getMinutes();
            if (mins < 10)
                mins = "0" + mins;
            var secs = date.getSeconds();
            if (secs < 10)
                secs = "0" + secs;

            $('.datepicker').datetimepicker({
                prevText: '',
                nextText: '',
                dateFormat: 'yy-mm-dd',
                timeFormat: 'hh:mm:ss',
            });
        });
    </script>
{/block}
