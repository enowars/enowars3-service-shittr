cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>When shit hits the fan...</h1>
        <p class="lead">...let's enjoy the shit show while the world is burning down and breaking apart!</p>
        <p>Social media has destroyed our lives. Social media is dead. Long live social media!</p>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF
