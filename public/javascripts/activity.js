//
// Functions for handling javascript clicks reporting
//
jQuery('document').ready(function() {
	// my funds page
	jQuery('a[data-trackable]').click(function(e){
	  var a = jQuery(this);
	  e.preventDefault();
	  jQuery.post('/update_my_fund_activity', { id: jQuery(this).data('trackable') }, function(){
	    window.location.href = a.attr('href');
	  });
	});

	// peer report create
	// TODO bug here window.locatio.href is bad for POST
	// links in chrome
	jQuery('a[data-creatable]').click(function(e){
	  var a = jQuery(this);
	  e.preventDefault();
	  jQuery.post('/create_report', { id: jQuery(this).data('creatable') }, function(){
	    window.location.href = a.attr('href');
	  });
	});

	//my fund show
	// TODO check this out!!!!
	jQuery('a[data-id]').click(function(e){
	  var a = jQuery(this);
	  e.preventDefault();
	  jQuery.post('/view_fund', { id: jQuery(this).data('id') }, function(){
	    window.location.href = a.attr('href');
	  });
	});
});