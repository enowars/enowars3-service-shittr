cat <<EOF
<footer class="">
    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-3">
                With <3 by <a href="https://twitter.com/gehaxelt">@gehaxelt</a>
            </div>
            <div class="col-lg-9">
                <div style="float: right">
                    <span>Server: $(serverTime)</span> <span>Generated in: $(pageTime)</span>
                </div>
            </div>
        </div>
    </div>
</footer>
<script src="/static/js/jquery-3.2.1.slim.min.js"></script>
<script>window.jQuery || document.write('<script src="/static/js/jquery-slim.min.js"><\/script>')</script>
<script src="/static/js/vendor/popper.min.js"></script>
<script src="/static/js/bootstrap.min.js"></script>
EOF