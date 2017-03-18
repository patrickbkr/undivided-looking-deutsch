document.addEventListener("DOMContentLoaded", function() {
    var x = ['e', 'd.', 'be', 'w', 'ye', 'lsa', 'eb'];
    x.splice(4, 0, '@');
    var k = x.join("").split("").reverse().join("");
    var element = document.getElementById('my-e-mail')
    if ( element !== null ) {
        element.innerHTML = '<a href="mailto:' + k + '" rel="nofollow">' + k + '</a>';
    }
});

