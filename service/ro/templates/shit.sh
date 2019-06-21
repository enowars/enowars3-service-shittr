cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>Take a dump!</h1>
        <div class="row">
          <div class="col-lg-6 offset-lg-3">
            <form method="post">
              <div class="form-group">
                <textarea name='post' class="form-control" placeholder="... and shit on the others!"></textarea>
              </div>
              <div class="form-group">
                <input type='checkbox' name='private' class="form-check-input">
                <label for='private' class="form-check-label">Private?</label>
              </div>
              <div class="form-group">
                <button type="submit"  class="btn btn-primary">Shit!</button>
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