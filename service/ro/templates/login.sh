cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>Login</h1>
        <div class="row">
          <div class="col-lg-6 offset-lg-3">
            <form method="POST">
              <div class="form-group">
                <label for="username">Username</label>
                <input type="text" name="username"  class="form-control">
              </div>
              <div class="form-group">
                <label for="password">Password</label>
                <input type="password" name="password"  class="form-control">
              </div>
              <div class="form-group">
                <button type="submit"  class="btn btn-primary">Login</button>
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