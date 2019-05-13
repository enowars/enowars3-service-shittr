cat <<EOF
<!doctype html>
<html lang="en">

$(render header.tpl)

  <body>

$(render navigation.tpl)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>World is going down!</h1>
        <p class="lead">Login!</p>
        <form method="POST">
            <input type="text" name="username">
            <input type="password" name="password">
            <input type="submit" name="submit">
        </form>
      </div>

    </main><!-- /.container -->

$(render footer.tpl)
  </body>
</html>
EOF