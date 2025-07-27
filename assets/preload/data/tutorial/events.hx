function beatHit()
{
  if (curBeat % 16 == 15 && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			boyfriend.canDance = false;
			dad.playAnim('cheer', true);
			dad.canDance = false;
		}
}