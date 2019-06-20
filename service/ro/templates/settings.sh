cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>$(htmlEscape "${TITLE}")</h1>
        <div class="row">
          <div class="col-lg-6 offset-lg-3">
            <form method="POST">
              <div class="form-group">
                <input  class="form-check-input" type='checkbox' name='public' $( [ "on" = "$isp" ] && echo -n "checked='checked'")>
                <label for='public' class="form-check-label">Public profile?</label>
              </div>
              <div class="form-group">
                <label for="bio">Biography</label>
                <textarea name='bio'  class="form-control">$(htmlEscape "${bio}")</textarea>
              </div>
              <div class="form-group">
                <button type="submit"  class="btn btn-primary">Save</button>
              </div>
            </form>
            <hr>
            <form method="POST" action='/download'>
              <p>GDPR sucks, but we don't give a shit about your data anyway..</p>
              <div class="form-group">
                <button type="submit"  name='downloadshits' class="btn btn-primary">Download shit!</button>
              </div>
            </form>
          </div>
        </div>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF