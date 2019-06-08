cat <<EOF
<!doctype html>
<html lang="en">

$(render header.sh)

  <body>

$(render navigation.sh)

    <main role="main" class="container">

      <div class="">
        $(render messages.sh)
        <div class="row">
          <div class="col-lg-3">
            <h1>@${OUSER}</h1>
          </div>
          <div class="col-lg-9">
            <h1>Following</h1>
            <table class="table table-dark table-striped table-hover"><tbody>
EOF
    for s in "${FOLLOWING[@]}";
    do
        cat <<EOF
              <tr>
                <td><a href='/@${s}'>@${s}</a></td>
              </tr>
EOF
    done
cat <<EOF
            </tbody></table>
          </div>
        </div>
      </div>

    </main><!-- /.container -->

$(render footer.sh)
  </body>
</html>
EOF