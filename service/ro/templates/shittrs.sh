cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="starter-template">
        $(render messages.sh)
        <h1>Here are your fellow shittrs, @${USERNAME}!</h1>
        <div class="row">
          <div class="col-lg-6 offset-lg-3">
            <table class="table table-dark table-striped table-hover"><tbody>
EOF
    for s in "${SHITTRS[@]}";
    do
        cat <<EOF
              <tr>
                <td><a href='/@${s}'>@${s}</a></td>
              </tr>
EOF
    done
cat <<EOF
        </div></div></tbody></table>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF