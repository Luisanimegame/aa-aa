function createPost()
{
    for (i in 0...instance.unspawnNotes.length)
    {
        if (instance.unspawnNotes[i].isSustainNote)
        {
            instance.unspawnNotes[i].noAnim = true;
        }
    }
}

function goodNoteHit(n, d, s, t)
{
    if (s) boyfriend.holdTimer = 0;
}
function opponentNoteHit(n, d, s, t)
{
    if (s) dad.holdTimer = 0;
}