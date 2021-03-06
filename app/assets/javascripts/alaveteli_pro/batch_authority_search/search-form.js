// Handles submission of the search form via ajax
(function($, BatchAuthoritySearch, DraftBatchSummary){
  var DraftEvents = DraftBatchSummary.Events;
  BatchAuthoritySearch.SearchForm = {};
  var $search,
      $draft,
      $form,
      $query,
      newDraft;

  // Submit the search form via AJAX.
  var submitForm = function submitForm(e) {
    if(typeof e !== 'undefined') {
      e.preventDefault();
    }
    BatchAuthoritySearch.startNewXHR();
    var formData = {
      authority_query: $query.val(),
      draft_id: DraftBatchSummary.draftId
    };
    BatchAuthoritySearch.currentXHR = $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      dataType: 'html',
      data: formData
    });
    BatchAuthoritySearch.bindXHR();
    return false;
  };

  $(function(){
    $search = BatchAuthoritySearch.$el;
    $draft = DraftBatchSummary.$el;
    $form = $('.js-batch-authority-search-form');
    $query = $('.js-batch-authority-search-form-query');
    newDraft = typeof DraftBatchSummary.draftId === 'undefined';

    BatchAuthoritySearch.SearchForm.$el = $form;

    $form.on('submit', submitForm);
    // We debounce this because otherwise it'll send (and then abort) a new
    // request for every keystroke, which would hammer the server
    $query.on('keypress', $.debounce(500, submitForm));

    // The very first time a body is added, a new draft object is saved, and
    // we need to resubmit the form in order to reload all the search results
    // with new pagination that contains the draft id, and new results that
    // have forms to add bodies rather than create a new draft.
    $draft.on(DraftEvents.bodyAdded, function() {
      if(newDraft) {
        newDraft = false;
        submitForm();
      }
    });
  });
})(window.jQuery,
   window.AlaveteliPro.BatchAuthoritySearch,
   window.AlaveteliPro.DraftBatchSummary);
