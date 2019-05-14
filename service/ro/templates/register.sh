cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>Register now!</h1>
        <form method="POST">
            <input type="text" name="username">
            <input type="password" name="password">
            <input type="submit" name="submit">
        </form>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF
