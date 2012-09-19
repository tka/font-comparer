$(function() {
    // FIXME: should remember the preference in cookie
    $('.calendar-view-toggle').on('click', function() {
        $('.calendar-view').show();
        $('.list-view').hide();
    });
    $('.list-view-toggle').on('click', function() {
        $('.list-view').show();
        $('.calendar-view').hide();
    }).trigger('click');

    $('a[rel="tooltip"]').tooltip({ placement: 'right' });
});
