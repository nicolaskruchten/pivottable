$(function(){ 
    $.getScript("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/highlight.min.js", function(){
        $("head").append($('<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/styles/default.min.css">'));
        $("body script").each(function(){
            $("#output").before($("<pre>").append(
                $("<code class='javascript'>").text($(this).text())
            ));
            $('pre code').each(function(i, block) {
                hljs.highlightBlock(block);
              });        
        });
    });
});