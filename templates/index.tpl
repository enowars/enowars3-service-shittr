cat <<EOF
<!doctype html>
<html lang="en">

$(render header.tpl)

  <body>

$(render navigation.tpl)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>World is going down!</h1>
        <p class="lead">Lorem ipsum dolor sit...</p>
      </div>

    </main><!-- /.container -->

$(render footer.tpl)
  </body>
</html>
EOF
