// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

var StorageManager = (function(){
    var _storage = window.sessionStorage;
    function support(){
        return (typeof _storage != "undefined");
    }
    return {
        save:function(key,value){
            if(support())
            _storage[key]=value;
        },
        get:function(key){
            if(!support())return null;
            return _storage[key];
        },
        has:function(key){
            if(!support())return false;
            return _storage[key]?true:false;
        }
    }
})();

var MarkupPreview=(function(){
    var lastMarkup = null;
    var lastFormat = null;
    var lastLayout = null;
    var delay = 1000;
    
    var timeout = 0;

    function resizeHandler(){
        if(lastLayout=="exact"){
            $("#right").css("width","852px");
            $("#left").css("width",($(document).width()-852-1)+"px");
        }else{
            $(".part").css("width","49.9999%");
        }
        $("#right .content").height($(window).height()-95+1);
        $("textarea").height($(window).height()-95+1)
        $("textarea").width($("#left").width()-34)
    }

    function update(){
        clearTimeout(timeout);

        var latest = $("textarea").val();
        var type = $("#type").val();
        if(latest==lastMarkup&&lastType == type){
            timeout = setTimeout(update,delay);
            return;
        }

        lastMarkup = latest;
        lastType = type;
        StorageManager.save("data",lastMarkup);
        StorageManager.save("type",lastType);
        
        $.ajax({
            type: "POST",
            url:    "./render",
            data: {
                type: $("#type").val(),
                markup: lastMarkup
            }
        }).success(function(data){
            $("#right .content").html(data);
            resizeHandler();
            timeout = setTimeout(update,delay);
        });
    }


    return {
        init:function(){
            $("header .btn-group .btn").click(function(){
                $("button.active").removeClass("active");
                $(this).addClass("active")
                if($(this).attr("id")=="50-50"){
                    lastLayout="50-50";
                }else{
                    lastLayout="exact";
                }
                resizeHandler();
                StorageManager.save("layout",lastLayout);
            })

            if(StorageManager.has("data")){
                $("textarea").val(StorageManager.get("data"));
            }else{ //first time visit
                $.ajax({
                    url: "./example.rdoc",
                }).success(function(data){
                    $("textarea").val(data);
                    resizeHandler();
                    update();
                });
            }
            if(StorageManager.has("type")){
                $("#type :contains('"+StorageManager.get("type")+"')").attr("selected","selected");
            }
            if(StorageManager.has("layout")){
                $("#"+StorageManager.get("layout")).trigger("click")
            }
            
            $("#type").change(update);
            $(window).resize(resizeHandler);
            resizeHandler();
            update();
        }
    }

})();

$(document).ready(function(){
    MarkupPreview.init();
})

