cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="">
        $(render messages.sh)
        <h1 style="text-align: center">The world's biggest shit stream!</h1>
        <table class="table table-hover table-striped table-dark">
        <tbody>
EOF
        for s in "${SHITS[@]}"
        do  
          cat <<EOF
        <tr>
          <td>${s}</td>
        </tr>
EOF
        done
cat <<EOF
      </tbody>
      </table>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF