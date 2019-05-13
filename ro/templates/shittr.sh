cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        <h1>${TITLE}</h1>
        <ul>
        </ul>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF