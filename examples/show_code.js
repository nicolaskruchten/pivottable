$(function(){ 
    $.getScript("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/highlight.min.js", function(){
        $("head").append(
        $('<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/styles/color-brewer.min.css">'),
        $("<link href='https://fonts.googleapis.com/css?family=Source+Code+Pro' rel='stylesheet' type='text/css'>")
        );
        $("body script").each(function(){
            $("#output").before($("<pre>").append(
                $("<code class='javascript'>").text($(this).text())
                .css({"font-family": "Source Code Pro"})
            ));
            $('pre code').each(function(i, block) {
                hljs.highlightBlock(block);
              });        
        });
    });
});