(function($) {

  //Autocomplete to list members
  $('#filter-name-autocomplete').autocomplete({
   minLength:2,
   source:function(request,response){
      $.ajax({
        url:document.location.pathname+'/search_members',
        dataType:'json',
        data:{
          filter_name:request.term
        },
        success:response
      });
   }
  });

})(jQuery);