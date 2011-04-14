// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function step2() {
  $('register').setStyle({display:'block'});
  $('personalize').setStyle({display:'none'});	  
  Modalbox.resizeToContent();
  return true;
}

function change_background(check_id, item_id)
{ check_id = $(check_id); 
  block_id = $("item_block_" + item_id); 
  if(check_id.checked == true) { block_id.style.backgroundColor = '#aecfe4';}
  else {block_id.style.backgroundColor = '#fff'; } 
}

function fbs_click() {
  u=location.href; t=document.title;
  window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(u)+'&t='+encodeURIComponent(t),' sharer', 'toolbar=0, status=0,   width=626, height=436'); return false;
}

function fb_init() {
  window.fbAsyncInit = function() {
    FB.init({appId: '128791437166443', status: true, cookie: true,xfbml: true});
  };

  (function() {
    var e = document.createElement('script');
    e.type = 'text/javascript';
    e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
    e.async = true;
    $('fb-root').appendChild(e);
  }());
}

function to_mydeals() {
  parent.location.href='/my';
}

function get_cookie(c_name) {
  if (document.cookie.length>0) {
    c_start=document.cookie.indexOf(c_name + "=");
    if (c_start!=-1) {
      c_start=c_start + c_name.length+1;
      c_end=document.cookie.indexOf(";",c_start);
      if (c_end==-1) c_end=document.cookie.length;
      return unescape(document.cookie.substring(c_start,c_end));
    }
  }
  return "";
}

function sidebar_item_type_updater(id,name) {    

  if ($('itype_link_'+id).classNames().include('sidebar_selected') == true) {
	deselect_item_type(id,name)
  } else {
    if (id >= 16) {
	  $('itype_link_'+id).removeClassName("sidebar_unselected");
	  $('itype_link_'+id).addClassName("sidebar_selected");
	
	  $('menu_item_types_'+id).removeClassName('menu_item_types_unselected_'+id);
	  $('menu_item_types_'+id).addClassName('menu_item_types_selected_'+id);
	
	}
  }

  new Ajax.Request('/items/filter', {
	asynchronous:true, 
	evalScripts:true, 
	method:"get", 
	parameters:{
		item_type_name:name, 
		dom_id: 'loading_category_'+id
	}, 
	onLoading: $('loading_category_'+id).show()
  }); 
}

function deselect_item_type(id,name) {

  $('itype_link_'+id).removeClassName("sidebar_selected");
  $('itype_link_'+id).addClassName("sidebar_unselected");

  $('menu_item_types_'+id).removeClassName('menu_item_types_selected_'+id);
  $('menu_item_types_'+id).addClassName('menu_item_types_unselected_'+id);

}

function sidebar_category_updater(id,name) {

  if ($('categ_link_'+id).classNames().include('sidebar_selected') == true) {
	deselect_category(id,name)
  } else {
	select_category(id,name)
  }	

  new Ajax.Request('/items/filter', {
    asynchronous:true, 
	evalScripts:true, 
	parameters:{
		category_name: name,
		dom_id: 'loading_location_'+id
	},
	onLoading: $('loading_location_'+id).show()
  });
}

function deselect_category(id,name) {
  $('categ_link_'+id).removeClassName("sidebar_selected");
  $('categ_link_'+id).addClassName("sidebar_unselected");

  $('menu_locations_'+id).removeClassName('menu_locations_selected_'+id);
  $('menu_locations_'+id).addClassName('menu_locations_unselected_'+id);
}

function select_category(id,name) {
  $('categ_link_'+id).removeClassName("sidebar_unselected");
  $('categ_link_'+id).addClassName("sidebar_selected");

  $('menu_locations_'+id).removeClassName('menu_locations_unselected_'+id);
  $('menu_locations_'+id).addClassName('menu_locations_selected_'+id); 
}


function admin_select(str_ids) {
  var arr_ids = str_ids.split(",");

  for (i=0;i < arr_ids.length;i++) {	
    $('item_type_select_form_'+arr_ids[i]).show();
    $('item_type_select_name_'+arr_ids[i]).hide();
    $('categories_select_form_'+arr_ids[i]).show();
    $('categories_select_name_'+arr_ids[i]).hide();
  }	
  $('submit_select').show();
}

function admin_select_categories(str_ids,item_id) {
  var arr_ids = str_ids.split(",");
  
  $('none_categories_'+item_id).checked = false
  for (i=0;i < arr_ids.length;i++) {
    $('item_'+item_id+'_category_ids_'+arr_ids[i]).checked=true;
  }	
}

function admin_none_categories(str_ids,item_id) {
  var arr_ids = str_ids.split(",");
  
  $('all_categories_'+item_id).checked = false
  if ($('none_categories_'+item_id).checked == true) {
    for (i=0;i < arr_ids.length;i++) {
      $('item_'+item_id+'_category_ids_'+arr_ids[i]).checked=false;
    }
  }
}

function admin_select_categories_edit(str_ids) {
  var arr_ids = str_ids.split(",");
  
  for (i=0;i < arr_ids.length;i++) {
    $('item_category_ids_'+arr_ids[i]).checked=true;
  }	
}

function admin_all_images_local(str_ids) {
  var arr_ids = str_ids.split(",");

  for (i=0;i < arr_ids.length;i++) {
    $('image_location_'+arr_ids[i]).checked=true;
  }	
}




